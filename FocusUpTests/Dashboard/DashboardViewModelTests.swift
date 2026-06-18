//
//  DashboardViewModelTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
@Suite(.tags(.dashboard, .production))
struct DashboardViewModelTests {
  private func makeOrchestrator(
    statisticsRepository: any StatisticsRepository,
    taskRepository: any TaskRepository
  ) -> DashboardOrchestrator {
    DashboardOrchestrator(
      statisticsRepository: statisticsRepository,
      taskRepository: taskRepository,
      focusSessionManager: FocusSessionManager(
        repository: PreviewFocusRepository(),
        ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
      ),
      restSessionManager: RestSessionManager(
        repository: PreviewRestRepository(),
        ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
      )
    )
  }

  @Test
  func loadPopulatesSnapshot() async throws {
    let viewModel = DashboardViewModel(
      orchestrator: makeOrchestrator(
        statisticsRepository: PreviewStatisticsRepository(),
        taskRepository: PreviewTaskRepository()
      )
    )

    await viewModel.load()

    #expect(viewModel.loadingState == .loaded)
    #expect(viewModel.snapshot.mood != .activeFocus)
    #expect(viewModel.sessionActionError == nil)
  }

  @Test
  func loadFailureSetsFailedState() async {
    struct FailingStatisticsRepository: StatisticsRepository {
      func fetchSummary() async throws -> FocusStatisticsSummary {
        throw NSError(domain: "test", code: 1)
      }

      func fetchAnalytics() async throws -> StatisticsSummary {
        throw NSError(domain: "test", code: 1)
      }

      func invalidateCache() {}
    }

    let viewModel = DashboardViewModel(
      orchestrator: makeOrchestrator(
        statisticsRepository: FailingStatisticsRepository(),
        taskRepository: PreviewTaskRepository()
      )
    )

    await viewModel.load()

    guard case .failed = viewModel.loadingState else {
      Issue.record("Expected failed loading state")
      return
    }
  }

  @Test
  func refreshInvalidatesStatisticsCache() async throws {
    let viewModel = DashboardViewModel(
      orchestrator: makeOrchestrator(
        statisticsRepository: PreviewStatisticsRepository(),
        taskRepository: PreviewTaskRepository()
      )
    )

    await viewModel.load()
    await viewModel.refresh()

    #expect(viewModel.loadingState == .loaded)
  }

  @Test
  func pauseAndResumeSessionUpdateSnapshot() async throws {
    let focusManager = FocusSessionManager(
      repository: PreviewFocusRepository(),
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
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
    let viewModel = DashboardViewModel(orchestrator: orchestrator)

    let session = DomainFixtures.focusSession(title: "Pause test", status: .active, segmentStartedAt: .now)
    focusManager.configureForPreview(
      session: session,
      timerSnapshot: TimerSnapshot(
        state: .running,
        configuration: .defaultFocus,
        accumulatedElapsedSeconds: 30,
        segmentStartedAt: .now,
        lastUpdatedAt: .now
      )
    )
    await viewModel.load()

    await viewModel.pauseSession()
    #expect(viewModel.isPerformingSessionAction == false)
    #expect(viewModel.sessionActionError == nil)

    await viewModel.resumeSession()
    #expect(viewModel.sessionActionError == nil)
  }

  @Test
  func sessionActionSurfacesErrors() async throws {
    let focusManager = FocusSessionManager(
      repository: PreviewFocusRepository(),
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    let viewModel = DashboardViewModel(
      orchestrator: DashboardOrchestrator(
        statisticsRepository: PreviewStatisticsRepository(),
        taskRepository: PreviewTaskRepository(),
        focusSessionManager: focusManager,
        restSessionManager: RestSessionManager(
          repository: PreviewRestRepository(),
          ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
        )
      )
    )

    await viewModel.pauseSession()

    #expect(viewModel.sessionActionError != nil)
  }

  @Test
  func navigationHelpersDelegateToCoordinator() async throws {
    let viewModel = DashboardViewModel(
      orchestrator: makeOrchestrator(
        statisticsRepository: PreviewStatisticsRepository(),
        taskRepository: PreviewTaskRepository()
      )
    )
    let coordinator = AppCoordinator(selectedTab: .dashboard)

    viewModel.openFocusSession(using: coordinator)
    #expect(coordinator.selectedTab == AppTab.focus)

    viewModel.openRestSession(using: coordinator)
    #expect(coordinator.selectedTab == AppTab.focus)

    let taskID = UUID()
    viewModel.openTask(taskID, using: coordinator)
    #expect(coordinator.selectedTab == AppTab.tasks)
    #expect(coordinator.tabCoordinators.tasks.path == [.detail(taskID)])
  }

  @Test
  func refreshActiveTaskTitleLoadsAssociatedTask() async throws {
    let task = DomainFixtures.task(title: "Linked task")
    let taskRepository = MockTaskRepository(tasks: [task])
    let focusManager = FocusSessionManager(
      repository: PreviewFocusRepository(),
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    var session = DomainFixtures.focusSession(title: "Focus", status: .active, segmentStartedAt: .now)
    session.associatedTaskID = task.id
    focusManager.configureForPreview(
      session: session,
      timerSnapshot: TimerSnapshot(
        state: .running,
        configuration: .defaultFocus,
        accumulatedElapsedSeconds: 10,
        segmentStartedAt: .now,
        lastUpdatedAt: .now
      )
    )

    let viewModel = DashboardViewModel(
      orchestrator: DashboardOrchestrator(
        statisticsRepository: PreviewStatisticsRepository(),
        taskRepository: taskRepository,
        focusSessionManager: focusManager,
        restSessionManager: RestSessionManager(
          repository: PreviewRestRepository(),
          ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
        )
      )
    )

    await viewModel.refreshActiveTaskTitle()

    #expect(viewModel.activeTaskTitle == "Linked task")
  }
}
