//
//  SessionLifecycleRunner.swift
//  FocusUp
//

import Foundation

/// Shared pause / resume / complete / cancel / tick / restore pipeline for timed sessions.
@MainActor
final class SessionLifecycleRunner<Session: TimedPersistableSession> {
  let timerEngine: TimerEngine
  private(set) var activeSession: Session?
  var lastError: String?

  private let clock: any Clock
  private let store: SessionLifecycleStore<Session>
  private var sideEffects: SessionLifecycleSideEffects<Session>

  init(
    clock: any Clock,
    store: SessionLifecycleStore<Session>,
    sideEffects: SessionLifecycleSideEffects<Session>? = nil
  ) {
    self.clock = clock
    self.store = store
    self.sideEffects = sideEffects ?? SessionLifecycleSideEffects()
    timerEngine = TimerEngine(clock: clock)
  }

  func activateNewSession(_ session: Session, durationSeconds: Int) async throws {
    if activeSession != nil {
      throw SessionLifecycleError.sessionAlreadyActive
    }

    let now = clock.now()
    let configuration = TimerConfiguration(totalDurationSeconds: durationSeconds)
    timerEngine.reset(configuration: configuration)
    timerEngine.start(at: now)

    var mutable = session
    mutable.applyTimerSnapshotForPersistence(timerEngine.exportSnapshot(at: now), at: now)
    try await persist(mutable)
    await sideEffects.onAfterStart?(mutable, now)
  }

  func pauseSession() async throws {
    guard var session = activeSession else {
      throw SessionLifecycleError.noActiveSession
    }

    let now = clock.now()
    timerEngine.pause(at: now)
    session.applyTimerSnapshotForPersistence(timerEngine.exportSnapshot(at: now), at: now)
    try await persist(session)
    await sideEffects.onAfterPause?(session, now)
  }

  func resumeSession() async throws {
    guard var session = activeSession else {
      throw SessionLifecycleError.noActiveSession
    }

    let now = clock.now()
    timerEngine.resume(at: now)
    session.applyTimerSnapshotForPersistence(timerEngine.exportSnapshot(at: now), at: now)
    try await persist(session)
    sideEffects.playAmbientSound?()
    await sideEffects.onAfterResume?(session, now)
  }

  func completeSession() async throws {
    guard var session = activeSession else {
      throw SessionLifecycleError.noActiveSession
    }

    let now = clock.now()
    timerEngine.complete(at: now)
    session.applyTimerSnapshotForPersistence(timerEngine.exportSnapshot(at: now), at: now)
    session.completedAt = now
    try await persist(session)
    activeSession = nil
    timerEngine.reset()
    await sideEffects.onAfterComplete?(session, now)
  }

  func cancelSession() async throws {
    guard var session = activeSession else {
      throw SessionLifecycleError.noActiveSession
    }

    let now = clock.now()
    timerEngine.cancel(at: now)
    session.applyTimerSnapshotForPersistence(timerEngine.exportSnapshot(at: now), at: now)
    try await persist(session)
    activeSession = nil
    timerEngine.reset()
    await sideEffects.onAfterCancel?(session, now)
  }

  func tick() async -> TimerSnapshot {
    let priorState = timerEngine.state
    let snapshot = timerEngine.tick(at: clock.now())
    if priorState != .completed, snapshot.state == .completed {
      try? await completeSession()
    }
    return snapshot
  }

  func restoreOnLaunch() async {
    guard activeSession == nil else { return }
    guard let session = try? await store.fetchActive() else { return }
    applyRestoredSession(session)
    if let activeSession {
      await sideEffects.onAfterRestore?(activeSession, clock.now())
    }
  }

  func applyRestorationSnapshot(_ snapshot: SessionTimerRestorationSnapshot) async {
    let reconciled = TimerRestorationManager.reconcile(snapshot, at: clock.now())
    guard let session = try? await store.fetch(reconciled.sessionID) else { return }
    guard session.status.isActiveLifecycle else { return }

    if reconciled.timerSnapshot.state == .completed || reconciled.timerSnapshot.state == .cancelled {
      var finalized = session
      finalized.applyTimerSnapshotForPersistence(reconciled.timerSnapshot, at: clock.now())
      if reconciled.timerSnapshot.state == .completed {
        finalized.completedAt = clock.now()
      }
      try? await store.save(finalized)
      return
    }

    activeSession = session
    timerEngine.restore(from: reconciled.timerSnapshot)
    timerEngine.reconcileAfterRestore(at: clock.now())
    if var updated = activeSession {
      updated.applyTimerSnapshotForPersistence(timerEngine.exportSnapshot(at: clock.now()), at: clock.now())
      activeSession = updated
      try? await store.save(updated)
    }
    syncAmbientSoundWithActiveSession()
    if let activeSession {
      await sideEffects.onAfterRestoreSync?(activeSession, clock.now())
    }
  }

  func exportRestorationSnapshot() -> SessionTimerRestorationSnapshot? {
    guard let session = activeSession else { return nil }
    return SessionTimerRestorationSnapshot(
      sessionID: session.id,
      timerSnapshot: timerEngine.exportSnapshot(at: clock.now())
    )
  }

  func syncAmbientSoundWithActiveSession() {
    if activeSession?.status.timerState == .running {
      sideEffects.playAmbientSound?()
    } else {
      sideEffects.stopAmbientSound?()
    }
  }

  #if DEBUG
  func configureForPreview(session: Session, timerSnapshot: TimerSnapshot) {
    activeSession = session
    timerEngine.restore(from: timerSnapshot)
  }
  #endif

  private func persist(_ session: Session) async throws {
    try await store.save(session)
    activeSession = session
    lastError = nil
  }

  private func applyRestoredSession(_ session: Session) {
    activeSession = session
    rebuildTimer(from: session)
    timerEngine.reconcileAfterRestore(at: clock.now())
    syncAmbientSoundWithActiveSession()
  }

  private func rebuildTimer(from session: Session) {
    let configuration = TimerConfiguration(totalDurationSeconds: session.plannedDurationSeconds)
    timerEngine.reset(configuration: configuration)

    let snapshot = TimerSnapshot(
      state: session.status.timerState,
      configuration: configuration,
      accumulatedElapsedSeconds: session.elapsedSeconds,
      segmentStartedAt: session.segmentStartedAt,
      lastUpdatedAt: clock.now()
    )
    timerEngine.restore(from: snapshot)
  }
}
