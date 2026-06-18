//
//  AppContainerTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

@MainActor
struct AppContainerTests {
  private func makeLiveStyleContainer() throws -> AppContainer {
    let persistence = try PersistenceController(inMemory: true)
    return AppContainer(
      persistence: persistence,
      coordinator: AppCoordinator(selectedTab: .dashboard)
    )
  }

  @Test(.tags(.foundation, .dependencyInjection))
  func liveContainerProvidesCoordinator() throws {
    let container = try makeLiveStyleContainer()
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
