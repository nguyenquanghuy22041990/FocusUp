//
//  FocusSessionManager.swift
//  FocusUp
//

import Foundation
import Observation

enum FocusSessionManagerError: Error, Equatable {
  case sessionAlreadyActive
  case noActiveSession
  case sessionNotFound
}

@MainActor
@Observable
final class FocusSessionManager {
  private let repository: any FocusRepository
  private let clock: any Clock
  private let ambientSoundPlayer: any SessionAmbientSoundPlaying
  private let liveActivityManager: any LiveActivityManaging
  private let notificationScheduler: (any NotificationScheduling)?

  let timerEngine: TimerEngine

  private(set) var activeSession: FocusSession?
  var lastError: String?

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
    self.timerEngine = TimerEngine(clock: clock)
  }

  // MARK: - Lifecycle

  func startSession(
    title: String,
    durationSeconds: Int = TimerConfiguration.defaultFocus.totalDurationSeconds,
    associatedTaskID: UUID? = nil
  ) async throws {
    if activeSession != nil {
      throw FocusSessionManagerError.sessionAlreadyActive
    }

    let now = clock.now()
    let config = TimerConfiguration(totalDurationSeconds: durationSeconds)
    timerEngine.reset(configuration: config)
    timerEngine.start(at: now)

    var session = FocusSession(
      title: title,
      plannedDurationSeconds: durationSeconds,
      status: .active,
      segmentStartedAt: now,
      sessionStartedAt: now,
      associatedTaskID: associatedTaskID
    )
    session.applyTimerSnapshotForPersistence(timerEngine.exportSnapshot(at: now), at: now)

    try await repository.save(session)
    activeSession = session
    lastError = nil
    ambientSoundPlayer.play(category: .focus)
    await liveActivityManager.startFocus(session: session, now: now)
  }

  func pauseSession() async throws {
    guard var session = activeSession else { throw FocusSessionManagerError.noActiveSession }
    let now = clock.now()
    timerEngine.pause(at: now)
    session.applyTimerSnapshotForPersistence(timerEngine.exportSnapshot(at: now), at: now)
    try await persist(session)
    ambientSoundPlayer.stop()
    if let activeSession { await liveActivityManager.syncFocus(session: activeSession, now: now) }
  }

  func resumeSession() async throws {
    guard var session = activeSession else { throw FocusSessionManagerError.noActiveSession }
    let now = clock.now()
    timerEngine.resume(at: now)
    session.applyTimerSnapshotForPersistence(timerEngine.exportSnapshot(at: now), at: now)
    try await persist(session)
    ambientSoundPlayer.play(category: .focus)
    if let activeSession { await liveActivityManager.syncFocus(session: activeSession, now: now) }
  }

  func completeSession() async throws {
    guard var session = activeSession else { throw FocusSessionManagerError.noActiveSession }
    let now = clock.now()
    timerEngine.complete(at: now)
    session.applyTimerSnapshotForPersistence(timerEngine.exportSnapshot(at: now), at: now)
    session.completedAt = now
    try await persist(session)
    activeSession = nil
    timerEngine.reset()
    ambientSoundPlayer.stop()
    await liveActivityManager.end(immediate: true)
    await notificationScheduler?.notifySessionCompleted(
      title: session.title,
      sessionID: session.id
    )
  }

  func cancelSession() async throws {
    guard var session = activeSession else { throw FocusSessionManagerError.noActiveSession }
    let now = clock.now()
    timerEngine.cancel(at: now)
    session.applyTimerSnapshotForPersistence(timerEngine.exportSnapshot(at: now), at: now)
    try await persist(session)
    activeSession = nil
    timerEngine.reset()
    ambientSoundPlayer.stop()
    await liveActivityManager.end(immediate: true)
  }

  func tick() async -> TimerSnapshot {
    let priorState = timerEngine.state
    let snapshot = timerEngine.tick(at: clock.now())
    if priorState != .completed, snapshot.state == .completed {
      try? await completeSession()
    }
    return snapshot
  }

  // MARK: - Restoration

  func restoreOnLaunch() async {
    guard activeSession == nil else { return }
    guard let session = try? await repository.fetchActive() else { return }
    applyRestoredSession(session)
    if let activeSession {
      await liveActivityManager.startFocus(session: activeSession, now: clock.now())
    }
  }

  func applyRestorationSnapshot(_ snapshot: FocusTimerRestorationSnapshot) async {
    let reconciled = TimerRestorationManager.reconcile(snapshot, at: clock.now())
    guard let session = try? await repository.fetch(id: reconciled.sessionID) else { return }
    guard session.status.isActiveLifecycle else { return }

    if reconciled.timerSnapshot.state == .completed || reconciled.timerSnapshot.state == .cancelled {
      var finalized = session
      finalized.applyTimerSnapshotForPersistence(reconciled.timerSnapshot, at: clock.now())
      if reconciled.timerSnapshot.state == .completed {
        finalized.completedAt = clock.now()
      }
      try? await repository.save(finalized)
      return
    }

    activeSession = session
    timerEngine.restore(from: reconciled.timerSnapshot)
    timerEngine.reconcileAfterRestore(at: clock.now())
    if var updated = activeSession {
      updated.applyTimerSnapshotForPersistence(timerEngine.exportSnapshot(at: clock.now()), at: clock.now())
      activeSession = updated
      try? await repository.save(updated)
    }
    syncAmbientSoundWithActiveSession()
    if let activeSession {
      await liveActivityManager.syncFocus(session: activeSession, now: clock.now())
    }
  }

  #if DEBUG
  /// Configures in-memory state for SwiftUI previews. Not for production use.
  func configureForPreview(session: FocusSession, timerSnapshot: TimerSnapshot) {
    activeSession = session
    timerEngine.restore(from: timerSnapshot)
  }
  #endif

  func exportRestorationSnapshot() -> FocusTimerRestorationSnapshot? {
    guard let session = activeSession else { return nil }
    return FocusTimerRestorationSnapshot(
      sessionID: session.id,
      timerSnapshot: timerEngine.exportSnapshot(at: clock.now())
    )
  }

  // MARK: - Private

  private func persist(_ session: FocusSession) async throws {
    try await repository.save(session)
    activeSession = session
    lastError = nil
  }

  private func applyRestoredSession(_ session: FocusSession) {
    activeSession = session
    rebuildTimer(from: session)
    timerEngine.reconcileAfterRestore(at: clock.now())
    syncAmbientSoundWithActiveSession()
  }

  private func syncAmbientSoundWithActiveSession() {
    guard activeSession?.status == .active else {
      ambientSoundPlayer.stop()
      return
    }
    ambientSoundPlayer.play(category: .focus)
  }

  private static func defaultLiveActivityManager() -> any LiveActivityManaging {
    #if canImport(ActivityKit) && os(iOS)
    LiveActivityManager()
    #else
    NoOpLiveActivityManager()
    #endif
  }

  private func rebuildTimer(from session: FocusSession) {
    let config = TimerConfiguration(totalDurationSeconds: session.plannedDurationSeconds)
    timerEngine.reset(configuration: config)

    let snapshot = TimerSnapshot(
      state: session.status.timerState,
      configuration: config,
      accumulatedElapsedSeconds: session.elapsedSeconds,
      segmentStartedAt: session.segmentStartedAt,
      lastUpdatedAt: clock.now()
    )
    timerEngine.restore(from: snapshot)
  }
}
