//
//  RestTimerRestorationTests.swift
//  FocusUp
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct RestTimerRestorationTests {
  @Test(.tags(.rest))
  func managerAppliesSceneRestorationSnapshot() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let repository = RestRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()

    var session = RestSession(title: "Scene", status: .active)
    session.segmentStartedAt = clock.now()
    session.sessionStartedAt = clock.now()
    try await repository.save(session)

    let manager = RestSessionManager(
      repository: repository,
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    let restoration = RestTimerRestorationSnapshot(
      sessionID: session.id,
      timerSnapshot: TimerSnapshot(
        state: .running,
        configuration: TimerConfiguration(totalDurationSeconds: 60),
        accumulatedElapsedSeconds: 15,
        segmentStartedAt: clock.now(),
        lastUpdatedAt: clock.now()
      )
    )

    clock.advance(by: 10)
    await manager.applyRestorationSnapshot(restoration)

    #expect(manager.activeSession?.id == session.id)
    #expect(manager.timerEngine.elapsedSeconds() == 25)
  }
}
