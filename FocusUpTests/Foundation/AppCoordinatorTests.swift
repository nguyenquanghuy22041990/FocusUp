//
//  AppCoordinatorTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

@MainActor
struct AppCoordinatorTests {
  @Test(.tags(.foundation, .navigation))
  func selectTabUpdatesSelection() {
    let coordinator = AppCoordinator(selectedTab: .dashboard)
    coordinator.selectTab(.settings)
    #expect(coordinator.selectedTab == .settings)
  }

  @Test(.tags(.foundation, .navigation))
  func allTabsAreRegistered() {
    #expect(AppTab.allCases.count == 5)
    #expect(Set(AppTab.allCases.map(\.id)).count == 5)
  }

  @Test(.tags(.foundation, .navigation))
  func tabCoordinatorsStartEmpty() {
    let coordinator = AppCoordinator()
    #expect(coordinator.tabCoordinators.dashboard.path.isEmpty)
    #expect(coordinator.tabCoordinators.tasks.path.isEmpty)
    #expect(coordinator.tabCoordinators.focus.path.isEmpty)
    #expect(coordinator.tabCoordinators.statistics.path.isEmpty)
    #expect(coordinator.tabCoordinators.settings.path.isEmpty)
  }
}
