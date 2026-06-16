//
//  AppCoordinatorTabNavigationTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

@MainActor
struct AppCoordinatorTabNavigationTests {
  @Test(.tags(.navigation, .production))
  func openFocusTabWithoutSessionPopsToRoot() {
    let coordinator = AppCoordinator(selectedTab: .dashboard)
    coordinator.tabCoordinators.focus.push(.activeSession)

    coordinator.openFocusTab(hasActiveSession: false)

    #expect(coordinator.selectedTab == .focus)
    #expect(coordinator.tabCoordinators.focus.path.isEmpty)
  }

  @Test(.tags(.navigation, .production))
  func openFocusTabWithSessionPushesActiveRoute() {
    let coordinator = AppCoordinator(selectedTab: .dashboard)

    coordinator.openFocusTab(hasActiveSession: true)

    #expect(coordinator.selectedTab == .focus)
    #expect(coordinator.tabCoordinators.focus.path == [.activeSession])
  }

  @Test(.tags(.navigation, .production))
  func clearStaleFocusRoutesRemovesActiveSessionPath() {
    let coordinator = AppCoordinator()
    coordinator.tabCoordinators.focus.setPath([.activeSession, .history])

    coordinator.clearStaleFocusSessionRoutes(hasActiveSession: false)

    #expect(coordinator.tabCoordinators.focus.path == [.history])
  }
}
