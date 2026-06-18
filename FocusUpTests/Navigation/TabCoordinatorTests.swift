//
//  TabCoordinatorTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

@MainActor
struct TabCoordinatorTests {
  @Test(.tags(.foundation, .navigation))
  func pushPopAndPopToRoot() {
    let coordinator = TabCoordinator<DashboardRoute>()

    coordinator.push(.goals)
    coordinator.push(.insights)
    #expect(coordinator.path == [.goals, .insights])

    coordinator.pop()
    #expect(coordinator.path == [.goals])

    coordinator.popToRoot()
    #expect(coordinator.path.isEmpty)
  }

  @Test(.tags(.foundation, .navigation))
  func setPathReplacesNavigationStack() {
    let coordinator = TabCoordinator<TasksRoute>()
    coordinator.setPath([.today, .upcoming])
    #expect(coordinator.path == [.today, .upcoming])
  }
}
