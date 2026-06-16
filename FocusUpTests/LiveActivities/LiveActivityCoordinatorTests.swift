//
//  LiveActivityCoordinatorTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct LiveActivityCoordinatorTests {
  private func makeFocusManager(
    live: RecordingLiveActivityManager
  ) throws -> (FocusSessionManager, RecordingLiveActivityManager, TestClock, FocusRepositoryImpl) {
    let persistence = try PersistenceController(inMemory: true)
    let repository = FocusRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()
    let manager = FocusSessionManager(
      repository: repository,
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer(),
      liveActivityManager: live
    )
    return (manager, live, clock, repository)
  }

  @Test(.tags(.focus, .production))
  func startSessionStartsLiveActivity() async throws {
    let live = RecordingLiveActivityManager()
    let (manager, _, _, _) = try makeFocusManager(live: live)

    try await manager.startSession(title: "Deep work", durationSeconds: 120)

    #expect(live.startFocusCount == 1)
    #expect(live.lastStartFocusSessionID == manager.activeSession?.id)
    #expect(live.endCount == 0)
  }

  @Test(.tags(.focus, .production))
  func pauseSessionSyncsLiveActivity() async throws {
    let live = RecordingLiveActivityManager()
    let (manager, _, clock, _) = try makeFocusManager(live: live)
    try await manager.startSession(title: "Work", durationSeconds: 120)
    let startsBeforePause = live.syncFocusCount

    clock.advance(by: 10)
    try await manager.pauseSession()

    #expect(live.syncFocusCount == startsBeforePause + 1)
    #expect(manager.activeSession?.status == .paused)
  }

  @Test(.tags(.focus, .production))
  func completeSessionEndsLiveActivity() async throws {
    let live = RecordingLiveActivityManager()
    let (manager, _, _, _) = try makeFocusManager(live: live)
    try await manager.startSession(title: "Work", durationSeconds: 60)

    try await manager.completeSession()

    #expect(manager.activeSession == nil)
    #expect(live.endCount == 1)
    #expect(live.lastEndedImmediate == true)
  }

  @Test(.tags(.focus, .production))
  func cancelSessionEndsLiveActivityImmediately() async throws {
    let live = RecordingLiveActivityManager()
    let (manager, _, _, _) = try makeFocusManager(live: live)
    try await manager.startSession(title: "Work", durationSeconds: 60)

    try await manager.cancelSession()

    #expect(manager.activeSession == nil)
    #expect(live.endCount == 1)
    #expect(live.lastEndedImmediate == true)
  }

  @Test(.tags(.focus, .production))
  func restoreOnLaunchReconnectsLiveActivity() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let repository = FocusRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()
    let live = RecordingLiveActivityManager()

    var session = DomainFixtures.focusSession(title: "Restore", status: .active)
    session.segmentStartedAt = clock.now()
    session.sessionStartedAt = clock.now()
    try await repository.save(session)

    let manager = FocusSessionManager(
      repository: repository,
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer(),
      liveActivityManager: live
    )
    await manager.restoreOnLaunch()

    #expect(manager.activeSession?.id == session.id)
    #expect(live.startFocusCount == 1)
  }

  @Test(.tags(.focus, .production))
  func timerTickCompletionEndsLiveActivity() async throws {
    let live = RecordingLiveActivityManager()
    let (manager, _, clock, _) = try makeFocusManager(live: live)
    try await manager.startSession(title: "Tick", durationSeconds: 20)

    clock.advance(by: 25)
    _ = await manager.tick()

    #expect(live.endCount >= 1)
    #expect(live.lastEndedImmediate == true)
    #expect(manager.activeSession == nil)
  }

  @Test(.tags(.rest, .production))
  func restLifecycleCoordinatesLiveActivity() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let repository = RestRepositoryImpl(context: persistence.mainContext)
    let live = RecordingLiveActivityManager()
    let manager = RestSessionManager(
      repository: repository,
      clock: TestClock(),
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer(),
      liveActivityManager: live
    )

    try await manager.startSession(durationSeconds: 300)
    #expect(live.startRestCount == 1)

    try await manager.completeSession()
    #expect(live.endCount == 1)
    #expect(live.lastEndedImmediate == true)
  }
}
