//
//  RestSessionManagerTests.swift
//  FocusUp
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct RestSessionManagerTests {
  private func makeManager() throws -> (RestSessionManager, TestClock, RestRepositoryImpl) {
    let persistence = try PersistenceController(inMemory: true)
    let repository = RestRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()
    let manager = RestSessionManager(
      repository: repository,
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    return (manager, clock, repository)
  }

  @Test(.tags(.rest))
  func startPauseResumeLifecycle() async throws {
    let (manager, clock, repository) = try makeManager()

    try await manager.startSession(durationSeconds: 60)
    #expect(manager.activeSession?.status == .active)

    clock.advance(by: 10)
    try await manager.pauseSession()
    #expect(manager.activeSession?.status == .paused)

    clock.advance(by: 5)
    try await manager.resumeSession()
    clock.advance(by: 7)

    #expect(manager.timerEngine.elapsedSeconds() == 17)

    try await manager.completeSession()
    #expect(manager.activeSession == nil)
    #expect(try await repository.fetchActive() == nil)
  }

  @Test(.tags(.rest))
  func restoreOnLaunchRebuildsActiveSession() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let repository = RestRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()

    var session = RestSession(title: "Restore", elapsedSeconds: 8, status: .active)
    session.segmentStartedAt = clock.now()
    session.sessionStartedAt = clock.now()
    try await repository.save(session)

    let manager = RestSessionManager(
      repository: repository,
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    await manager.restoreOnLaunch()

    #expect(manager.activeSession?.id == session.id)
    clock.advance(by: 5)
    #expect(manager.timerEngine.elapsedSeconds() == 13)
  }

  @Test(.tags(.rest))
  func startFailsWhenSessionAlreadyActive() async throws {
    let (manager, _, _) = try makeManager()
    try await manager.startSession(durationSeconds: 30)
    await #expect(throws: RestSessionManagerError.sessionAlreadyActive) {
      try await manager.startSession(durationSeconds: 30)
    }
  }
}
