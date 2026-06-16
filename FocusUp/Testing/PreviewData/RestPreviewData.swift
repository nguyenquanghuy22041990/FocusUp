//
//  RestPreviewData.swift
//  FocusUp
//

import Foundation

enum RestPreviewData {
  private static let baseDate = Date(timeIntervalSince1970: 1_800_000_000)

  static var active: RestSession {
    RestSession(
      title: "Rest Break",
      plannedDurationSeconds: 15 * 60,
      elapsedSeconds: 5 * 60,
      status: .active,
      segmentStartedAt: baseDate.addingTimeInterval(-5 * 60),
      sessionStartedAt: baseDate.addingTimeInterval(-5 * 60)
    )
  }

  static var paused: RestSession {
    RestSession(
      title: "Rest Break",
      plannedDurationSeconds: 30 * 60,
      elapsedSeconds: 12 * 60,
      status: .paused,
      sessionStartedAt: baseDate.addingTimeInterval(-15 * 60)
    )
  }

  static var completed: RestSession {
    RestSession(
      title: "Rest Break",
      plannedDurationSeconds: 15 * 60,
      elapsedSeconds: 15 * 60,
      status: .completed,
      sessionStartedAt: baseDate.addingTimeInterval(-20 * 60),
      completedAt: baseDate
    )
  }

  static var all: [RestSession] {
    [active, paused, completed]
  }

  static var activeTimerSnapshot: TimerSnapshot {
    TimerSnapshot(
      state: .running,
      configuration: TimerConfiguration(totalDurationSeconds: 15 * 60),
      accumulatedElapsedSeconds: 5 * 60,
      segmentStartedAt: baseDate.addingTimeInterval(-5 * 60),
      lastUpdatedAt: baseDate
    )
  }

  static var pausedTimerSnapshot: TimerSnapshot {
    TimerSnapshot(
      state: .paused,
      configuration: TimerConfiguration(totalDurationSeconds: 30 * 60),
      accumulatedElapsedSeconds: 12 * 60,
      segmentStartedAt: nil,
      lastUpdatedAt: baseDate
    )
  }
}
