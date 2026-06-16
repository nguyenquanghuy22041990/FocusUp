//
//  MockAppCoordinatorTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

@MainActor
struct MockAppCoordinatorTests {
  @Test(.tags(.foundation))
  func factoryCreatesCoordinatorWithTab() {
    let coordinator = MockAppCoordinatorFactory.make(selectedTab: .statistics)
    #expect(coordinator.selectedTab == .statistics)
  }
}
