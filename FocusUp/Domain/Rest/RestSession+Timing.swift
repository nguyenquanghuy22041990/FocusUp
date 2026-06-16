//
//  RestSession+Timing.swift
//  FocusUp
//

import Foundation

extension RestSession {
  func elapsedSeconds(at date: Date = .now) -> Int {
    guard status == .active, let segmentStartedAt else {
      return elapsedSeconds
    }
    let segment = max(0, Int(date.timeIntervalSince(segmentStartedAt)))
    return elapsedSeconds + segment
  }

  func remainingSeconds(at date: Date = .now) -> Int {
    max(0, plannedDurationSeconds - elapsedSeconds(at: date))
  }

  var progress: Double {
    guard plannedDurationSeconds > 0 else { return 0 }
    return min(1, Double(elapsedSeconds) / Double(plannedDurationSeconds))
  }

  mutating func applyTimerSnapshotForPersistence(_ snapshot: TimerSnapshot, at date: Date = .now) {
    if snapshot.state == .running {
      elapsedSeconds = snapshot.accumulatedElapsedSeconds
      segmentStartedAt = snapshot.segmentStartedAt ?? date
    } else {
      elapsedSeconds = snapshot.elapsedSeconds(at: date)
      segmentStartedAt = nil
    }
    status = RestSessionStatus.from(timerState: snapshot.state)
    updatedAt = date
  }
}

extension RestSessionStatus {
  static func from(timerState: TimerState) -> RestSessionStatus {
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
