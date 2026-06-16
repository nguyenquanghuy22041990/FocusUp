//
//  FocusSessionManagerTests.swift
//  FocusUp
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct FocusSessionManagerTests {
  private func makeManager() throws -> (FocusSessionManager, TestClock, FocusRepositoryImpl) {
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

  @Test(.tags(.foundation))
  func startPauseResumeLifecycle() async throws {
    let (manager, clock, repository) = try makeManager()

    try await manager.startSession(title: "Work", durationSeconds: 60)
    #expect(manager.activeSession?.status == .active)

    clock.advance(by: 10)
    try await manager.pauseSession()
    #expect(manager.activeSession?.status == .paused)
    #expect(manager.activeSession?.elapsedSeconds == 10)

    clock.advance(by: 5)
    try await manager.resumeSession()
    clock.advance(by: 7)

    let snapshot = await manager.tick()
    #expect(snapshot.elapsedSeconds(at: clock.now()) == 17)

    try await manager.completeSession()
    #expect(manager.activeSession == nil)

    let active = try await repository.fetchActive()
    #expect(active == nil)

    let completed = try await repository.fetchCompleted()
    #expect(completed.count == 1)
    #expect(completed.first?.status == .completed)
  }

  @Test(.tags(.foundation))
  func restoreOnLaunchRebuildsActiveSession() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let repository = FocusRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()

    var session = DomainFixtures.focusSession(title: "Restore", status: .active)
    session.elapsedSeconds = 12
    session.segmentStartedAt = clock.now()
    session.sessionStartedAt = clock.now()
    try await repository.save(session)

    let manager = FocusSessionManager(
      repository: repository,
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    await manager.restoreOnLaunch()

    #expect(manager.activeSession?.id == session.id)
    clock.advance(by: 8)
    #expect(manager.timerEngine.elapsedSeconds() == 20)
  }

  @Test(.tags(.foundation))
  func startFailsWhenSessionAlreadyActive() async throws {
    let (manager, _, _) = try makeManager()
    try await manager.startSession(title: "One")
    await #expect(throws: FocusSessionManagerError.sessionAlreadyActive) {
      try await manager.startSession(title: "Two")
    }
  }
}
