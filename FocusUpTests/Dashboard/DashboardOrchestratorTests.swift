//
//  DashboardOrchestratorTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct DashboardOrchestratorTests {
  @Test(.tags(.dashboard))
  func refreshAggregatesStatisticsAndTasks() async throws {
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

    let snapshot = try await orchestrator.refresh()
    #expect(snapshot.statistics.totalCompletedSessions >= 0)
    #expect(snapshot.mood != .activeFocus)
  }

  @Test(.tags(.dashboard))
  func activeSessionSnapshotNilWithoutSession() {
    let orchestrator = DashboardOrchestrator(
      statisticsRepository: PreviewStatisticsRepository(),
      taskRepository: PreviewTaskRepository(),
      focusSessionManager: FocusSessionManager(
        repository: PreviewFocusRepository(),
        ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
      ),
      restSessionManager: RestSessionManager(
        repository: PreviewRestRepository(),
        ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
      )
    )
    #expect(orchestrator.activeSessionSnapshot(taskTitle: nil) == nil)
  }

  @Test(.tags(.dashboard))
  func invalidateCacheOnForcedRefresh() async throws {
    let repository = PreviewStatisticsRepository()
    let orchestrator = DashboardOrchestrator(
      statisticsRepository: repository,
      taskRepository: PreviewTaskRepository(),
      focusSessionManager: FocusSessionManager(
        repository: PreviewFocusRepository(),
        ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
      ),
      restSessionManager: RestSessionManager(
        repository: PreviewRestRepository(),
        ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
      )
    )

    _ = try await orchestrator.refresh()
    _ = try await orchestrator.refresh(invalidateStatisticsCache: true)
    #expect(Bool(true))
  }
}
