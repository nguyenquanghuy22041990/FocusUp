//
//  RestSessionManager.swift
//  FocusUp
//

import Foundation
import Observation

@MainActor
@Observable
final class RestSessionManager {
  private let repository: any RestRepository
  private let clock: any Clock
  private let ambientSoundPlayer: any SessionAmbientSoundPlaying
  private let liveActivityManager: any LiveActivityManaging
  private let lifecycle: SessionLifecycleRunner<RestSession>

  var activeSession: RestSession? { lifecycle.activeSession }
  var timerEngine: TimerEngine { lifecycle.timerEngine }
  var lastError: String? {
    get { lifecycle.lastError }
    set { lifecycle.lastError = newValue }
  }

  init(
    repository: any RestRepository,
    clock: any Clock = SystemClock(),
    ambientSoundPlayer: any SessionAmbientSoundPlaying,
    liveActivityManager: (any LiveActivityManaging)? = nil
  ) {
    self.repository = repository
    self.clock = clock
    self.ambientSoundPlayer = ambientSoundPlayer
    self.liveActivityManager = liveActivityManager ?? Self.defaultLiveActivityManager()

    let ambientSoundPlayer = ambientSoundPlayer
    let liveActivityManager = self.liveActivityManager

    lifecycle = SessionLifecycleRunner(
      clock: clock,
      store: SessionLifecycleStore(
        fetchActive: { try await repository.fetchActive() },
        fetch: { try await repository.fetch(id: $0) },
        save: { try await repository.save($0) }
      ),
      sideEffects: SessionLifecycleSideEffects(
        onAfterStart: { session, now in
          ambientSoundPlayer.play(category: .rest)
          await liveActivityManager.startRest(session: session, now: now)
        },
        onAfterPause: { session, now in
          ambientSoundPlayer.stop()
          await liveActivityManager.syncRest(session: session, now: now)
        },
        onAfterResume: { session, now in
          await liveActivityManager.syncRest(session: session, now: now)
        },
        onAfterComplete: { _, _ in
          ambientSoundPlayer.stop()
          await liveActivityManager.end(immediate: true)
        },
        onAfterCancel: { _, _ in
          ambientSoundPlayer.stop()
          await liveActivityManager.end(immediate: true)
        },
        onAfterRestore: { session, now in
          await liveActivityManager.startRest(session: session, now: now)
        },
        onAfterRestoreSync: { session, now in
          await liveActivityManager.syncRest(session: session, now: now)
        },
        playAmbientSound: {
          ambientSoundPlayer.play(category: .rest)
        },
        stopAmbientSound: {
          ambientSoundPlayer.stop()
        }
      )
    )
  }

  func startSession(
    title: String = "Rest Break",
    durationSeconds: Int
  ) async throws {
    let now = clock.now()
    let session = RestSession(
      title: title,
      plannedDurationSeconds: durationSeconds,
      status: .active,
      segmentStartedAt: now,
      sessionStartedAt: now
    )
    try await lifecycle.activateNewSession(session, durationSeconds: durationSeconds)
  }

  func pauseSession() async throws {
    try await lifecycle.pauseSession()
  }

  func resumeSession() async throws {
    try await lifecycle.resumeSession()
  }

  func completeSession() async throws {
    try await lifecycle.completeSession()
  }

  func cancelSession() async throws {
    try await lifecycle.cancelSession()
  }

  func tick() async -> TimerSnapshot {
    await lifecycle.tick()
  }

  func restoreOnLaunch() async {
    await lifecycle.restoreOnLaunch()
  }

  func applyRestorationSnapshot(_ snapshot: SessionTimerRestorationSnapshot) async {
    await lifecycle.applyRestorationSnapshot(snapshot)
  }

  #if DEBUG
  func configureForPreview(session: RestSession, timerSnapshot: TimerSnapshot) {
    lifecycle.configureForPreview(session: session, timerSnapshot: timerSnapshot)
  }
  #endif

  func exportRestorationSnapshot() -> SessionTimerRestorationSnapshot? {
    lifecycle.exportRestorationSnapshot()
  }

  func syncAmbientSoundWithActiveSession() {
    lifecycle.syncAmbientSoundWithActiveSession()
  }

  private static func defaultLiveActivityManager() -> any LiveActivityManaging {
    #if canImport(ActivityKit) && os(iOS)
    LiveActivityManager()
    #else
    NoOpLiveActivityManager()
    #endif
  }
}
