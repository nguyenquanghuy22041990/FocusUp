//
//  FocusSessionLifecycleStressTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct FocusSessionLifecycleStressTests {
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

  @Test(.tags(.foundation, .production))
  func cancelSessionPersistsTerminalState() async throws {
    let (manager, _, repository) = try makeManager()
    try await manager.startSession(title: "Cancel me", durationSeconds: 90)

    let sessionID = try #require(manager.activeSession?.id)
    try await manager.cancelSession()

    #expect(manager.activeSession == nil)
    #expect(try await repository.fetchActive() == nil)

    let stored = try await repository.fetch(id: sessionID)
    #expect(stored?.status == .cancelled)
  }

  @Test(.tags(.foundation, .production))
  func rapidPauseResumePreservesMonotonicElapsed() async throws {
    let (manager, clock, _) = try makeManager()
    try await manager.startSession(title: "Rapid", durationSeconds: 300)

    var lastElapsed = 0
    for _ in 0..<5 {
      clock.advance(by: 2)
      try await manager.pauseSession()
      let pausedElapsed = manager.timerEngine.elapsedSeconds()
      #expect(pausedElapsed >= lastElapsed)
      lastElapsed = pausedElapsed

      clock.advance(by: 1)
      try await manager.resumeSession()
      #expect(manager.timerEngine.elapsedSeconds() == pausedElapsed)
    }

    clock.advance(by: 3)
    let runningSeconds = 5 * 2 + 3
    let elapsed = manager.timerEngine.elapsedSeconds(at: clock.now())
    #expect(elapsed >= runningSeconds)
    #expect(elapsed <= runningSeconds + 1)
    #expect(elapsed >= lastElapsed)
    #expect(manager.activeSession?.status == .active)
  }

  @Test(.tags(.foundation, .production))
  func repeatedPauseResumeDoesNotCorruptTimerState() async throws {
    let (manager, clock, _) = try makeManager()
    try await manager.startSession(title: "Cycles", durationSeconds: 600)

    var lastElapsed = 0
    for cycle in 0..<8 {
      clock.advance(by: 4)
      try await manager.pauseSession()
      let pausedElapsed = manager.timerEngine.elapsedSeconds()
      #expect(pausedElapsed >= lastElapsed)

      clock.advance(by: 2)
      try await manager.resumeSession()
      lastElapsed = manager.timerEngine.elapsedSeconds(at: clock.now())
      #expect(manager.timerEngine.state == .running)
      #expect(lastElapsed >= pausedElapsed + (cycle == 0 ? 0 : 0))
    }
  }

  @Test(.tags(.foundation, .production))
  func tickAutoCompletesAtDurationBoundary() async throws {
    let (manager, clock, repository) = try makeManager()
    try await manager.startSession(title: "Short", durationSeconds: 20)

    clock.advance(by: 25)
    let snapshot = await manager.tick()

    #expect(snapshot.state == .completed)
    #expect(manager.activeSession == nil)
    #expect(try await repository.fetchActive() == nil)
    #expect(try await repository.fetchCompleted().count == 1)
  }
}
