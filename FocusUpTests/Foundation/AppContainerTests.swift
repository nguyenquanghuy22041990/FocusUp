//
//  AppContainerTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

@MainActor
struct AppContainerTests {
  @Test(.tags(.foundation, .dependencyInjection))
  func liveContainerProvidesCoordinator() {
    let container = AppContainer.live
    #expect(container.coordinator.selectedTab == .dashboard)
  }

  @Test(.tags(.foundation, .dependencyInjection))
  func testingContainerUsesIsolatedCoordinator() {
    let container = AppContainer.testing
    #expect(container.coordinator.selectedTab == .focus)
  }

  @Test(.tags(.foundation, .dependencyInjection))
  func previewContainerIsDeterministic() {
    let container = AppContainer.preview
    #expect(container.coordinator.selectedTab == .dashboard)
  }
}
