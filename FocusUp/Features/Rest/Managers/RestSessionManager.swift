//
//  RestSessionManager.swift
//  FocusUp
//

import Foundation
import Observation

enum RestSessionManagerError: Error, Equatable {
  case sessionAlreadyActive
  case noActiveSession
  case sessionNotFound
}

@MainActor
@Observable
final class RestSessionManager {
  private let repository: any RestRepository
  private let clock: any Clock
  private let ambientSoundPlayer: any SessionAmbientSoundPlaying
  private let liveActivityManager: any LiveActivityManaging

  let timerEngine: TimerEngine

  private(set) var activeSession: RestSession?
  var lastError: String?

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
    self.timerEngine = TimerEngine(clock: clock)
  }

  // MARK: - Lifecycle

  func startSession(
    title: String = "Rest Break",
    durationSeconds: Int
  ) async throws {
    if activeSession != nil {
      throw RestSessionManagerError.sessionAlreadyActive
    }

    let now = clock.now()
    let config = TimerConfiguration(totalDurationSeconds: durationSeconds)
    timerEngine.reset(configuration: config)
    timerEngine.start(at: now)

    var session = RestSession(
      title: title,
      plannedDurationSeconds: durationSeconds,
      status: .active,
      segmentStartedAt: now,
      sessionStartedAt: now
    )
    session.applyTimerSnapshotForPersistence(timerEngine.exportSnapshot(at: now), at: now)

    try await repository.save(session)
    activeSession = session
    lastError = nil
    ambientSoundPlayer.play(category: .rest)
    await liveActivityManager.startRest(session: session, now: now)
  }

  func pauseSession() async throws {
    guard var session = activeSession else { throw RestSessionManagerError.noActiveSession }
    let now = clock.now()
    timerEngine.pause(at: now)
    session.applyTimerSnapshotForPersistence(timerEngine.exportSnapshot(at: now), at: now)
    try await persist(session)
    ambientSoundPlayer.stop()
    if let activeSession { await liveActivityManager.syncRest(session: activeSession, now: now) }
  }

  func resumeSession() async throws {
    guard var session = activeSession else { throw RestSessionManagerError.noActiveSession }
    let now = clock.now()
    timerEngine.resume(at: now)
    session.applyTimerSnapshotForPersistence(timerEngine.exportSnapshot(at: now), at: now)
    try await persist(session)
    ambientSoundPlayer.play(category: .rest)
    if let activeSession { await liveActivityManager.syncRest(session: activeSession, now: now) }
  }

  func completeSession() async throws {
    guard var session = activeSession else { throw RestSessionManagerError.noActiveSession }
    let now = clock.now()
    timerEngine.complete(at: now)
    session.applyTimerSnapshotForPersistence(timerEngine.exportSnapshot(at: now), at: now)
    session.completedAt = now
    try await persist(session)
    activeSession = nil
    timerEngine.reset()
    ambientSoundPlayer.stop()
    await liveActivityManager.end(immediate: true)
  }

  func cancelSession() async throws {
    guard var session = activeSession else { throw RestSessionManagerError.noActiveSession }
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
      await liveActivityManager.startRest(session: activeSession, now: clock.now())
    }
  }

  func applyRestorationSnapshot(_ snapshot: RestTimerRestorationSnapshot) async {
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
      await liveActivityManager.syncRest(session: activeSession, now: clock.now())
    }
  }

  #if DEBUG
  func configureForPreview(session: RestSession, timerSnapshot: TimerSnapshot) {
    activeSession = session
    timerEngine.restore(from: timerSnapshot)
  }
  #endif

  func exportRestorationSnapshot() -> RestTimerRestorationSnapshot? {
    guard let session = activeSession else { return nil }
    return RestTimerRestorationSnapshot(
      sessionID: session.id,
      timerSnapshot: timerEngine.exportSnapshot(at: clock.now())
    )
  }

  // MARK: - Private

  private func persist(_ session: RestSession) async throws {
    try await repository.save(session)
    activeSession = session
    lastError = nil
  }

  private func applyRestoredSession(_ session: RestSession) {
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
    ambientSoundPlayer.play(category: .rest)
  }

  private static func defaultLiveActivityManager() -> any LiveActivityManaging {
    #if canImport(ActivityKit) && os(iOS)
    LiveActivityManager()
    #else
    NoOpLiveActivityManager()
    #endif
  }

  private func rebuildTimer(from session: RestSession) {
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
