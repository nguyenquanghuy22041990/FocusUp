//
//  SessionCoordinationTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct SessionCoordinationTests {
  @Test(.tags(.foundation, .production))
  func immersiveChromeActiveForFocusOrRest() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let focus = FocusSessionManager(
      repository: FocusRepositoryImpl(context: persistence.mainContext),
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    let rest = RestSessionManager(
      repository: RestRepositoryImpl(context: persistence.mainContext),
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )

    try await focus.startSession(title: "Focus", durationSeconds: 60)
    #expect(ActiveTimerTabBarVisibility.shouldHideTabBar(
      focusManager: focus,
      restManager: rest
    ))

    try await focus.cancelSession()
    try await rest.startSession(durationSeconds: 60)
    #expect(ActiveTimerTabBarVisibility.isImmersiveModeActive(
      focusManager: focus,
      restManager: rest
    ))
  }

  @Test(.tags(.foundation, .production))
  func completingFocusAllowsRestToStart() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let focus = FocusSessionManager(
      repository: FocusRepositoryImpl(context: persistence.mainContext),
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    let rest = RestSessionManager(
      repository: RestRepositoryImpl(context: persistence.mainContext),
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )

    try await focus.startSession(title: "Focus", durationSeconds: 30)
    try await focus.completeSession()
    #expect(focus.activeSession == nil)

    try await rest.startSession(durationSeconds: 60)
    #expect(rest.activeSession?.status.isActiveLifecycle == true)
    #expect(try await RestRepositoryImpl(context: persistence.mainContext).fetchActive() != nil)
  }

  @Test(.tags(.foundation, .production))
  func onlyOneActiveFocusSessionInRepository() async throws {
    let (manager, _, repository) = try makeFocusManager()
    try await manager.startSession(title: "One", durationSeconds: 60)

    await #expect(throws: FocusSessionManagerError.sessionAlreadyActive) {
      try await manager.startSession(title: "Two", durationSeconds: 60)
    }

    let activeSessions = try await repository.fetchAll().filter(\.status.isActiveLifecycle)
    #expect(activeSessions.count == 1)
  }

  @Test(.tags(.foundation, .production))
  func restoreOnLaunchDoesNotCreateDuplicateFocusRows() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let repository = FocusRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()

    var session = DomainFixtures.focusSession(title: "Single", status: .active)
    session.segmentStartedAt = clock.now()
    try await repository.save(session)

    let manager = FocusSessionManager(
      repository: repository,
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    await manager.restoreOnLaunch()
    await manager.restoreOnLaunch()

    let active = try await repository.fetchAll().filter(\.status.isActiveLifecycle)
    #expect(active.count == 1)
    #expect(manager.activeSession?.id == session.id)
  }

  private func makeFocusManager() throws -> (FocusSessionManager, TestClock, FocusRepositoryImpl) {
    let persistence = try PersistenceController(inMemory: true)
    let repository = FocusRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()
    let manager = FocusSessionManager(
      repository: repository,
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    return (manager, clock, repository)
  }
}
