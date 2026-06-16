//
//  TimerRestorationTests.swift
//  FocusUp
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct TimerRestorationTests {
  @Test(.tags(.foundation))
  func encodeDecodeRoundTrip() {
    let snapshot = FocusTimerRestorationSnapshot(
      sessionID: UUID(),
      timerSnapshot: FocusPreviewData.activeTimerSnapshot,
      savedAt: Date()
    )

    let data = TimerRestorationManager.encode(snapshot)
    #expect(data != nil)

    let decoded = TimerRestorationManager.decode(data)
    #expect(decoded?.sessionID == snapshot.sessionID)
    #expect(decoded?.timerSnapshot.state == snapshot.timerSnapshot.state)
    #expect(decoded?.timerSnapshot.accumulatedElapsedSeconds == snapshot.timerSnapshot.accumulatedElapsedSeconds)
  }

  @Test(.tags(.foundation))
  func reconcileCompletesExpiredRunningTimer() {
    let clock = TestClock(startingAt: Date(timeIntervalSince1970: 4_000_000))
    var timer = TimerSnapshot(
      state: .running,
      configuration: TimerConfiguration(totalDurationSeconds: 30),
      accumulatedElapsedSeconds: 25,
      segmentStartedAt: clock.now(),
      lastUpdatedAt: clock.now()
    )

    let original = FocusTimerRestorationSnapshot(sessionID: UUID(), timerSnapshot: timer)
    clock.advance(by: 10)

    let reconciled = TimerRestorationManager.reconcile(original, at: clock.now())
    #expect(reconciled.timerSnapshot.state == .completed)
    #expect(reconciled.timerSnapshot.accumulatedElapsedSeconds == 30)
  }

  @Test(.tags(.foundation))
  func managerAppliesSceneRestorationSnapshot() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let repository = FocusRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()

    var session = DomainFixtures.focusSession(title: "Scene", status: .active)
    session.segmentStartedAt = clock.now()
    session.sessionStartedAt = clock.now()
    try await repository.save(session)

    let manager = FocusSessionManager(
      repository: repository,
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    let restoration = FocusTimerRestorationSnapshot(
      sessionID: session.id,
      timerSnapshot: TimerSnapshot(
        state: .running,
        configuration: TimerConfiguration(totalDurationSeconds: 60),
        accumulatedElapsedSeconds: 20,
        segmentStartedAt: clock.now(),
        lastUpdatedAt: clock.now()
      )
    )

    clock.advance(by: 15)
    await manager.applyRestorationSnapshot(restoration)

    #expect(manager.activeSession?.id == session.id)
    #expect(manager.timerEngine.elapsedSeconds() == 35)
  }

  @Test(.tags(.foundation))
  func sceneRestorationIgnoresCompletedSession() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let repository = FocusRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()

    var session = DomainFixtures.focusSession(title: "Done", status: .completed)
    session.completedAt = clock.now()
    try await repository.save(session)

    let manager = FocusSessionManager(
      repository: repository,
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    let restoration = FocusTimerRestorationSnapshot(
      sessionID: session.id,
      timerSnapshot: TimerSnapshot(
        state: .running,
        configuration: TimerConfiguration(totalDurationSeconds: 60),
        accumulatedElapsedSeconds: 10,
        segmentStartedAt: clock.now(),
        lastUpdatedAt: clock.now()
      )
    )

    await manager.applyRestorationSnapshot(restoration)

    #expect(manager.activeSession == nil)
    #expect(try await repository.fetchActive() == nil)
  }
}
