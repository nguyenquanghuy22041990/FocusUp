//
//  AppForegroundRefreshTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct AppForegroundRefreshTests {
  @Test(.tags(.production))
  func foregroundRefreshClearsStaleRoutes() async {
    let container = AppContainer.testing
    if container.focusSessionManager.activeSession != nil {
      try? await container.focusSessionManager.cancelSession()
    }
    container.coordinator.tabCoordinators.focus.setPath([.activeSession])

    await AppForegroundRefresh.perform(using: container)

    #expect(container.focusSessionManager.activeSession == nil)
    #expect(container.coordinator.tabCoordinators.focus.path.isEmpty)
  }

  @Test(.tags(.production))
  func foregroundRefreshPreservesActiveSessionRoute() async throws {
    let container = AppContainer.testing
    let repository = container.focusRepository
    var session = DomainFixtures.focusSession(title: "Active", status: .active)
    session.segmentStartedAt = .now
    try await repository.save(session)

    let manager = container.focusSessionManager
    await manager.restoreOnLaunch()
    container.coordinator.tabCoordinators.focus.popToRoot()

    await AppForegroundRefresh.perform(using: container)

    #expect(manager.activeSession != nil)
  }
}
