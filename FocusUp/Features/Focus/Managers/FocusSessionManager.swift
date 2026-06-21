//
//  FocusSessionManager.swift
//  FocusUp
//

import Foundation
import Observation

@MainActor
@Observable
final class FocusSessionManager {
  private let repository: any FocusRepository
  private let clock: any Clock
  private let ambientSoundPlayer: any SessionAmbientSoundPlaying
  private let liveActivityManager: any LiveActivityManaging
  private let notificationScheduler: (any NotificationScheduling)?
  private let lifecycle: SessionLifecycleRunner<FocusSession>

  var activeSession: FocusSession? { lifecycle.activeSession }
  var timerEngine: TimerEngine { lifecycle.timerEngine }
  var lastError: String? {
    get { lifecycle.lastError }
    set { lifecycle.lastError = newValue }
  }

  init(
    repository: any FocusRepository,
    clock: any Clock = SystemClock(),
    ambientSoundPlayer: any SessionAmbientSoundPlaying,
    liveActivityManager: (any LiveActivityManaging)? = nil,
    notificationScheduler: (any NotificationScheduling)? = nil
  ) {
    self.repository = repository
    self.clock = clock
    self.ambientSoundPlayer = ambientSoundPlayer
    self.liveActivityManager = liveActivityManager ?? Self.defaultLiveActivityManager()
    self.notificationScheduler = notificationScheduler

    let ambientSoundPlayer = ambientSoundPlayer
    let liveActivityManager = self.liveActivityManager
    let notificationScheduler = notificationScheduler

    lifecycle = SessionLifecycleRunner(
      clock: clock,
      store: SessionLifecycleStore(
        fetchActive: { try await repository.fetchActive() },
        fetch: { try await repository.fetch(id: $0) },
        save: { try await repository.save($0) }
      ),
      sideEffects: SessionLifecycleSideEffects(
        onAfterStart: { session, now in
          ambientSoundPlayer.play(category: .focus)
          await liveActivityManager.startFocus(session: session, now: now)
        },
        onAfterPause: { session, now in
          ambientSoundPlayer.stop()
          await liveActivityManager.syncFocus(session: session, now: now)
        },
        onAfterResume: { session, now in
          await liveActivityManager.syncFocus(session: session, now: now)
        },
        onAfterComplete: { session, _ in
          ambientSoundPlayer.stop()
          await liveActivityManager.end(immediate: true)
          await notificationScheduler?.notifySessionCompleted(
            title: session.title,
            sessionID: session.id
          )
        },
        onAfterCancel: { _, _ in
          ambientSoundPlayer.stop()
          await liveActivityManager.end(immediate: true)
        },
        onAfterRestore: { session, now in
          await liveActivityManager.startFocus(session: session, now: now)
        },
        onAfterRestoreSync: { session, now in
          await liveActivityManager.syncFocus(session: session, now: now)
        },
        playAmbientSound: {
          ambientSoundPlayer.play(category: .focus)
        },
        stopAmbientSound: {
          ambientSoundPlayer.stop()
        }
      )
    )
  }

  func startSession(
    title: String,
    durationSeconds: Int = TimerConfiguration.defaultFocus.totalDurationSeconds,
    associatedTaskID: UUID? = nil
  ) async throws {
    let now = clock.now()
    let session = FocusSession(
      title: title,
      plannedDurationSeconds: durationSeconds,
      status: .active,
      segmentStartedAt: now,
      sessionStartedAt: now,
      associatedTaskID: associatedTaskID
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
  func configureForPreview(session: FocusSession, timerSnapshot: TimerSnapshot) {
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
