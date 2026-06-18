//
//  NavigationRestorationTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct NavigationRestorationTests {
  @Test(.tags(.foundation, .navigation))
  func encodeDecodeRoundTripPreservesState() throws {
    let original = PersistedNavigationState(
      selectedTab: .focus,
      dashboardPath: [.weeklyOverview],
      tasksPath: [.today],
      focusPath: [.sessionSetup, .history],
      statisticsPath: [],
      settingsPath: [.about]
    )

    let data = try #require(NavigationRestorationManager.encode(original))
    let decoded = try #require(NavigationRestorationManager.decode(data))

    #expect(decoded == original)
  }

  @Test(.tags(.foundation, .navigation))
  func coordinatorExportAndApplyRoundTrip() {
    let coordinator = AppCoordinator(selectedTab: .statistics)
    coordinator.tabCoordinators.statistics.push(.weeklyChart)
    coordinator.tabCoordinators.settings.push(.appearance)

    let snapshot = coordinator.exportRestorationState()
    let restored = AppCoordinator()
    restored.applyRestorationState(snapshot)

    #expect(restored.selectedTab == .statistics)
    #expect(restored.tabCoordinators.statistics.path == [.weeklyChart])
    #expect(restored.tabCoordinators.settings.path == [.appearance])
    #expect(restored.tabCoordinators.dashboard.path.isEmpty)
  }

  @Test(.tags(.foundation, .navigation))
  func decodeEmptyDataReturnsNil() {
    #expect(NavigationRestorationManager.decode(nil) == nil)
    #expect(NavigationRestorationManager.decode(Data()) == nil)
  }
}
