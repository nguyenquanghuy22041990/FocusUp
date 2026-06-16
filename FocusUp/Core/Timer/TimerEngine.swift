//
//  TimerEngine.swift
//  FocusUp
//

import Foundation
import Observation

/// Timestamp-based timer engine. Safe for TimelineView and restoration.
@MainActor
@Observable
final class TimerEngine {
  private(set) var snapshot: TimerSnapshot
  private let clock: any Clock

  init(
    configuration: TimerConfiguration = .defaultFocus,
    clock: any Clock = SystemClock()
  ) {
    self.clock = clock
    self.snapshot = TimerSnapshot(configuration: configuration)
  }

  var state: TimerState { snapshot.state }

  func elapsedSeconds(at date: Date? = nil) -> Int {
    snapshot.elapsedSeconds(at: date ?? clock.now())
  }

  func remainingSeconds(at date: Date? = nil) -> Int {
    snapshot.remainingSeconds(at: date ?? clock.now())
  }

  func progress(at date: Date? = nil) -> Double {
    let now = date ?? clock.now()
    guard snapshot.configuration.totalDurationSeconds > 0 else { return 0 }
    return min(
      1,
      Double(elapsedSeconds(at: now)) / Double(snapshot.configuration.totalDurationSeconds)
    )
  }

  // MARK: - Lifecycle

  func start(at date: Date? = nil) {
    let now = date ?? clock.now()
    snapshot = TimerSnapshot(
      state: .running,
      configuration: snapshot.configuration,
      accumulatedElapsedSeconds: 0,
      segmentStartedAt: now,
      lastUpdatedAt: now
    )
  }

  func pause(at date: Date? = nil) {
    guard snapshot.state == .running else { return }
    let now = date ?? clock.now()
    let accumulated = snapshot.elapsedSeconds(at: now)
    snapshot = TimerSnapshot(
      state: .paused,
      configuration: snapshot.configuration,
      accumulatedElapsedSeconds: accumulated,
      segmentStartedAt: nil,
      lastUpdatedAt: now
    )
  }

  func resume(at date: Date? = nil) {
    guard snapshot.state == .paused else { return }
    let now = date ?? clock.now()
    snapshot = TimerSnapshot(
      state: .running,
      configuration: snapshot.configuration,
      accumulatedElapsedSeconds: snapshot.accumulatedElapsedSeconds,
      segmentStartedAt: now,
      lastUpdatedAt: now
    )
  }

  @discardableResult
  func stop(at date: Date? = nil) -> Bool {
    guard snapshot.state == .running || snapshot.state == .paused else { return false }
    let now = date ?? clock.now()
    let accumulated = snapshot.state == .running
      ? snapshot.elapsedSeconds(at: now)
      : snapshot.accumulatedElapsedSeconds
    let didComplete = accumulated >= snapshot.configuration.totalDurationSeconds
    snapshot = TimerSnapshot(
      state: didComplete ? .completed : .cancelled,
      configuration: snapshot.configuration,
      accumulatedElapsedSeconds: min(accumulated, snapshot.configuration.totalDurationSeconds),
      segmentStartedAt: nil,
      lastUpdatedAt: now
    )
    return didComplete
  }

  func complete(at date: Date? = nil) {
    let now = date ?? clock.now()
    let elapsed = snapshot.elapsedSeconds(at: now)
    snapshot = TimerSnapshot(
      state: .completed,
      configuration: snapshot.configuration,
      accumulatedElapsedSeconds: min(elapsed, snapshot.configuration.totalDurationSeconds),
      segmentStartedAt: nil,
      lastUpdatedAt: now
    )
  }

  func cancel(at date: Date? = nil) {
    let now = date ?? clock.now()
    let accumulated = snapshot.state == .running
      ? snapshot.elapsedSeconds(at: now)
      : snapshot.accumulatedElapsedSeconds
    snapshot = TimerSnapshot(
      state: .cancelled,
      configuration: snapshot.configuration,
      accumulatedElapsedSeconds: accumulated,
      segmentStartedAt: nil,
      lastUpdatedAt: now
    )
  }

  func reset(configuration: TimerConfiguration? = nil) {
    snapshot = TimerSnapshot(
      configuration: configuration ?? snapshot.configuration
    )
  }

  // MARK: - Restoration

  func restore(from restored: TimerSnapshot) {
    snapshot = restored
  }

  func exportSnapshot(at date: Date? = nil) -> TimerSnapshot {
    var copy = snapshot
    copy.lastUpdatedAt = date ?? clock.now()
    return copy
  }

  /// Recalculates running elapsed after relaunch/interruption.
  func reconcileAfterRestore(at date: Date? = nil) {
    let now = date ?? clock.now()
    guard snapshot.state == .running else {
      snapshot.lastUpdatedAt = now
      return
    }

    if snapshot.isComplete {
      complete(at: now)
      return
    }

    snapshot.lastUpdatedAt = now
    if snapshot.segmentStartedAt == nil {
      snapshot.segmentStartedAt = now
    }
  }

  func tick(at date: Date? = nil) -> TimerSnapshot {
    let now = date ?? clock.now()
    if snapshot.state == .running, snapshot.remainingSeconds(at: now) <= 0 {
      complete(at: now)
    }
    snapshot.lastUpdatedAt = now
    return snapshot
  }
}
