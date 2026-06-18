//
//  TimerSnapshot.swift
//  FocusUp
//

import Foundation

/// Restoration-safe timer snapshot using timestamp-based elapsed tracking.
struct TimerSnapshot: Codable, Equatable, Sendable {
  var state: TimerState
  var configuration: TimerConfiguration
  /// Elapsed seconds from completed running segments (excludes current segment).
  var accumulatedElapsedSeconds: Int
  /// Start of the current running segment; nil when paused or idle.
  var segmentStartedAt: Date?
  var lastUpdatedAt: Date

  init(
    state: TimerState = .idle,
    configuration: TimerConfiguration = .defaultFocus,
    accumulatedElapsedSeconds: Int = 0,
    segmentStartedAt: Date? = nil,
    lastUpdatedAt: Date = .now
  ) {
    self.state = state
    self.configuration = configuration
    self.accumulatedElapsedSeconds = accumulatedElapsedSeconds
    self.segmentStartedAt = segmentStartedAt
    self.lastUpdatedAt = lastUpdatedAt
  }

  func elapsedSeconds(at date: Date) -> Int {
    guard state == .running, let segmentStartedAt else {
      return accumulatedElapsedSeconds
    }
    let segment = max(0, Int(date.timeIntervalSince(segmentStartedAt)))
    return accumulatedElapsedSeconds + segment
  }

  func remainingSeconds(at date: Date) -> Int {
    max(0, configuration.totalDurationSeconds - elapsedSeconds(at: date))
  }

  var progress: Double {
    guard configuration.totalDurationSeconds > 0 else { return 0 }
    return min(1, Double(elapsedSeconds(at: lastUpdatedAt)) / Double(configuration.totalDurationSeconds))
  }

  var isComplete: Bool {
    remainingSeconds(at: lastUpdatedAt) <= 0 && state == .running
  }
}
