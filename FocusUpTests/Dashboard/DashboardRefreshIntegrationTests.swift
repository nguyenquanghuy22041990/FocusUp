//
//  DashboardRefreshIntegrationTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct DashboardRefreshIntegrationTests {
  @Test(.tags(.dashboard, .production))
  func refreshReflectsCompletedTaskInAnalytics() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let context = persistence.mainContext
    let taskRepo = TaskRepositoryImpl(context: context)
    let statsRepo = StatisticsRepositoryImpl(context: context)
    let focusRepo = FocusRepositoryImpl(context: context)

    var task = DomainFixtures.task(title: "Ship feature", status: .todo)
    try await taskRepo.create(task)
    task.status = .completed
    try await taskRepo.update(task)

    var session = DomainFixtures.focusSession(title: "Work", status: .completed)
    session.completedAt = .now
    session.elapsedSeconds = 1_500
    try await focusRepo.save(session)

    let orchestrator = DashboardOrchestrator(
      statisticsRepository: statsRepo,
      taskRepository: taskRepo,
      focusSessionManager: FocusSessionManager(
        repository: focusRepo,
        ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
      ),
      restSessionManager: RestSessionManager(
        repository: RestRepositoryImpl(context: context),
        ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
      )
    )

    let snapshot = try await orchestrator.refresh()

    #expect(snapshot.statistics.completedTasksCount >= 1)
    #expect(snapshot.statistics.totalCompletedSessions >= 1)
    #expect(!snapshot.hasOpenTasks || snapshot.priorities.isEmpty)
  }

  @Test(.tags(.dashboard, .production))
  func refreshSurfacesOverdueTaskAfterRepositoryUpdate() async throws {
    let taskRepo = MockTaskRepository()
    let orchestrator = DashboardOrchestrator(
      statisticsRepository: PreviewStatisticsRepository(),
      taskRepository: taskRepo,
      focusSessionManager: FocusSessionManager(
        repository: PreviewFocusRepository(),
        ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
      ),
      restSessionManager: RestSessionManager(
        repository: PreviewRestRepository(),
        ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
      )
    )

    let initial = try await orchestrator.refresh()
    #expect(initial.priorities.isEmpty || initial.priorities.first?.title != "Overdue item")

    taskRepo.tasks = [
      Task(
        title: "Overdue item",
        deadline: Date().addingTimeInterval(-3_600),
        priority: .high,
        status: .todo
      )
    ]

    let updated = try await orchestrator.refresh()
    #expect(updated.priorities.first?.title == "Overdue item")
    #expect(updated.priorities.first?.reason.lowercased().contains("overdue") == true)
  }

  @Test(.tags(.dashboard, .production))
  func activeSessionSnapshotUpdatesWithTimerEngine() async throws {
    let focusManager = FocusSessionManager(
      repository: PreviewFocusRepository(),
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    let session = FocusSession(
      title: "Live",
      plannedDurationSeconds: 100,
      elapsedSeconds: 10,
      status: .active,
      segmentStartedAt: .now
    )
    focusManager.configureForPreview(
      session: session,
      timerSnapshot: TimerSnapshot(
        state: .running,
        configuration: TimerConfiguration(totalDurationSeconds: 100),
        accumulatedElapsedSeconds: 10,
        segmentStartedAt: .now,
        lastUpdatedAt: .now
      )
    )

    let orchestrator = DashboardOrchestrator(
      statisticsRepository: PreviewStatisticsRepository(),
      taskRepository: PreviewTaskRepository(),
      focusSessionManager: focusManager,
      restSessionManager: RestSessionManager(
        repository: PreviewRestRepository(),
        ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
      )
    )

    let early = orchestrator.activeSessionSnapshot(at: .now, taskTitle: nil)
    focusManager.timerEngine.tick(at: Date().addingTimeInterval(30))
    let later = orchestrator.activeSessionSnapshot(
      at: Date().addingTimeInterval(30),
      taskTitle: nil
    )

    #expect(early?.remainingSeconds ?? 0 > later?.remainingSeconds ?? 0)
    #expect((later?.progress ?? 0) > (early?.progress ?? 0))
  }

  @Test(.tags(.dashboard, .production))
  func moodBecomesActiveFocusWhenSessionRunning() async throws {
    let focusManager = FocusSessionManager(
      repository: PreviewFocusRepository(),
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    focusManager.configureForPreview(
      session: FocusSession(title: "Active", status: .active, segmentStartedAt: .now),
      timerSnapshot: TimerSnapshot(
        state: .running,
        configuration: .defaultFocus,
        accumulatedElapsedSeconds: 5,
        segmentStartedAt: .now,
        lastUpdatedAt: .now
      )
    )

    let orchestrator = DashboardOrchestrator(
      statisticsRepository: PreviewStatisticsRepository(),
      taskRepository: PreviewTaskRepository(),
      focusSessionManager: focusManager,
      restSessionManager: RestSessionManager(
        repository: PreviewRestRepository(),
        ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
      )
    )

    let snapshot = try await orchestrator.refresh()
    #expect(snapshot.mood == .activeFocus)
    #expect(snapshot.continuity.hasActiveFocus)
  }
}
