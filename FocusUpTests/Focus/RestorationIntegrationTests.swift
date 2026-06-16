//
//  RestorationIntegrationTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct RestorationIntegrationTests {
  @Test(.tags(.foundation, .production))
  func restoreOnLaunchIsIdempotent() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let repository = FocusRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()

    var session = DomainFixtures.focusSession(title: "Once", status: .active)
    session.segmentStartedAt = clock.now()
    session.sessionStartedAt = clock.now()
    try await repository.save(session)

    let manager = FocusSessionManager(
      repository: repository,
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )

    await manager.restoreOnLaunch()
    let firstID = manager.activeSession?.id
    let firstElapsed = manager.timerEngine.elapsedSeconds()

    await manager.restoreOnLaunch()
    #expect(manager.activeSession?.id == firstID)
    #expect(manager.timerEngine.elapsedSeconds() == firstElapsed)
    #expect(try await repository.fetchActive()?.id == session.id)
  }

  @Test(.tags(.foundation, .production))
  func restoreOnLaunchSkipsWhenSessionAlreadyLoaded() async throws {
    let (manager, clock, _) = try makeManager()
    try await manager.startSession(title: "Live", durationSeconds: 120)
    clock.advance(by: 15)
    let elapsedBefore = manager.timerEngine.elapsedSeconds()

    await manager.restoreOnLaunch()

    #expect(manager.timerEngine.elapsedSeconds() == elapsedBefore)
  }

  @Test(.tags(.foundation, .production))
  func sceneRestoreAfterElapsedTimeReconcilesProgress() async throws {
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
    await manager.restoreOnLaunch()

    let exported = manager.exportRestorationSnapshot()
    clock.advance(by: 25)
    guard let exported else {
      Issue.record("Expected exportable restoration snapshot")
      return
    }

    await manager.applyRestorationSnapshot(exported)

    #expect(manager.activeSession != nil)
    #expect(manager.timerEngine.elapsedSeconds() >= 25)
    #expect(try await repository.fetchActive()?.id == session.id)
  }

  @Test(.tags(.foundation, .production))
  func forceQuitStyleReconcileCompletesExpiredRunningTimer() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let repository = FocusRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()

    var session = DomainFixtures.focusSession(
      title: "Expired",
      status: .active,
      plannedDurationSeconds: 30
    )
    session.segmentStartedAt = clock.now()
    try await repository.save(session)

    let snapshot = FocusTimerRestorationSnapshot(
      sessionID: session.id,
      timerSnapshot: TimerSnapshot(
        state: .running,
        configuration: TimerConfiguration(totalDurationSeconds: 30),
        accumulatedElapsedSeconds: 28,
        segmentStartedAt: clock.now(),
        lastUpdatedAt: clock.now()
      )
    )

    clock.advance(by: 10)
    let manager = FocusSessionManager(
      repository: repository,
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    await manager.applyRestorationSnapshot(snapshot)

    #expect(manager.activeSession == nil)
    #expect(try await repository.fetchActive() == nil)
  }

  @Test(.tags(.foundation, .production))
  func malformedSceneSnapshotDecodeReturnsNil() {
    let garbage = Data("not-valid-json".utf8)
    #expect(TimerRestorationManager.decode(garbage) == nil)
    #expect(TimerRestorationManager.decode(nil) == nil)
  }

  @Test(.tags(.foundation, .production))
  func encodeDecodeRoundTripPreservesSessionID() {
    let snapshot = FocusTimerRestorationSnapshot(
      sessionID: UUID(),
      timerSnapshot: FocusPreviewData.activeTimerSnapshot
    )
    let data = TimerRestorationManager.encode(snapshot)
    let decoded = TimerRestorationManager.decode(data)
    #expect(decoded?.sessionID == snapshot.sessionID)
  }

  // MARK: - Helpers

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
}
