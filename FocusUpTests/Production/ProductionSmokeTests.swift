//
//  ProductionSmokeTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

@MainActor
struct ProductionSmokeTests {
  @Test(.tags(.production))
  func liveContainerInitializes() {
    let container = AppContainer.live
    #expect(container.coordinator.selectedTab == .dashboard)
    #expect(container.focusSessionManager.activeSession == nil)
    #expect(container.restSessionManager.activeSession == nil)
  }

  @Test(.tags(.production))
  func appMetadataProvidesVersion() {
    #expect(!AppMetadata.displayName.isEmpty)
    #expect(AppMetadata.versionString.contains("("))
  }

  @Test(.tags(.production))
  func dashboardOrchestratorProducesSnapshot() async throws {
    let container = AppContainer.testing
    let orchestrator = DashboardOrchestrator(
      statisticsRepository: container.statisticsRepository,
      taskRepository: container.taskRepository,
      focusSessionManager: container.focusSessionManager,
      restSessionManager: container.restSessionManager
    )
    let snapshot = try await orchestrator.refresh()
    #expect(snapshot.mood != .activeFocus || orchestrator.hasActiveFocusSession)
  }

  @Test(.tags(.production))
  func motionPolicyRespectsReducedFlags() {
    #expect(FocusMotionPolicy.isReduced(systemReduceMotion: true, appPrefersReducedMotion: false))
    #expect(FocusMotion.animation(reduced: true, style: .progress) == nil)
  }
}
