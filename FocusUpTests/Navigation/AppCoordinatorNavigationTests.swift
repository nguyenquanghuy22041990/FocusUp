//
//  AppCoordinatorNavigationTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

@MainActor
struct AppCoordinatorNavigationTests {
  @Test(.tags(.foundation, .navigation))
  func deepLinkOpensTabAndRoute() {
    let coordinator = AppCoordinator()
    coordinator.open(.tasks(.completed))

    #expect(coordinator.selectedTab == .tasks)
    #expect(coordinator.tabCoordinators.tasks.path == [.completed])
  }

  @Test(.tags(.foundation, .navigation))
  func tabDeepLinkClearsPath() {
    let coordinator = AppCoordinator()
    coordinator.tabCoordinators.dashboard.push(.goals)
    coordinator.open(.tab(.dashboard))

    #expect(coordinator.selectedTab == .dashboard)
    #expect(coordinator.tabCoordinators.dashboard.path.isEmpty)
  }

  @Test(.tags(.foundation, .navigation))
  func popToRootClearsTabPath() {
    let coordinator = AppCoordinator()
    coordinator.tabCoordinators.focus.push(.history)
    coordinator.popToRoot(for: .focus)

    #expect(coordinator.tabCoordinators.focus.path.isEmpty)
  }
}
