//
//  FocusSession+Timing.swift
//  FocusUp
//

import Foundation

extension FocusSession {
  /// Live elapsed time using timestamp-based segment tracking.
  func elapsedSeconds(at date: Date = .now) -> Int {
    guard status == .active, let segmentStartedAt else {
      return elapsedSeconds
    }
    let segment = max(0, Int(date.timeIntervalSince(segmentStartedAt)))
    return elapsedSeconds + segment
  }

  var duration: FocusDuration {
    FocusDuration.from(session: self)
  }

  func remainingSeconds(at date: Date = .now) -> Int {
    max(0, plannedDurationSeconds - elapsedSeconds(at: date))
  }

  var progress: Double {
    duration.progress
  }

  mutating func syncFromTimerSnapshot(_ snapshot: TimerSnapshot, at date: Date = .now) {
    elapsedSeconds = snapshot.elapsedSeconds(at: date)
    segmentStartedAt = snapshot.state == .running ? snapshot.segmentStartedAt : nil
    status = FocusSessionStatus.from(timerState: snapshot.state)
    updatedAt = date
  }

  mutating func applyTimerSnapshotForPersistence(_ snapshot: TimerSnapshot, at date: Date = .now) {
    if snapshot.state == .running {
      elapsedSeconds = snapshot.accumulatedElapsedSeconds
      segmentStartedAt = snapshot.segmentStartedAt ?? date
    } else {
      elapsedSeconds = snapshot.elapsedSeconds(at: date)
      segmentStartedAt = nil
    }
    status = FocusSessionStatus.from(timerState: snapshot.state)
    updatedAt = date
  }
}

extension FocusSessionStatus {
  static func from(timerState: TimerState) -> FocusSessionStatus {
    switch timerState {
    case .idle: .planned
    case .running: .active
    case .paused: .paused
    case .completed: .completed
    case .cancelled: .cancelled
    }
  }

  var timerState: TimerState {
    switch self {
    case .planned: .idle
    case .active: .running
    case .paused: .paused
    case .completed: .completed
    case .cancelled: .cancelled
    }
  }
}
