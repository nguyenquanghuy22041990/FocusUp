//
//  DashboardSynchronizationTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct DashboardSynchronizationTests {
  @Test(.tags(.dashboard, .production))
  func viewModelReflectsActiveSessionAfterContinuityChange() async throws {
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

    await viewModel.load()
    #expect(viewModel.hasActiveSession == false)

    let session = FocusSession(title: "Sync", status: .active, segmentStartedAt: .now)
    let snapshot = TimerSnapshot(
      state: .running,
      configuration: .defaultFocus,
      accumulatedElapsedSeconds: 60,
      segmentStartedAt: .now,
      lastUpdatedAt: .now
    )
    focusManager.configureForPreview(session: session, timerSnapshot: snapshot)

    await viewModel.onSessionContinuityChanged()

    #expect(viewModel.hasActiveSession)
    #expect(viewModel.snapshot.mood == .activeFocus)
    #expect(viewModel.activeSession(at: .now) != nil)
  }
}
