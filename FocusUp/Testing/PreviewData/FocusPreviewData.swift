//
//  FocusPreviewData.swift
//  FocusUp
//

import Foundation

enum FocusPreviewData {
  private static let baseDate = Date(timeIntervalSince1970: 1_700_000_000)

  static var planned: FocusSession {
    FocusSession(title: "Planned Session", status: .planned)
  }

  static var active: FocusSession {
    FocusSession(
      title: "Active Focus",
      plannedDurationSeconds: 25 * 60,
      elapsedSeconds: 8 * 60,
      status: .active,
      segmentStartedAt: baseDate.addingTimeInterval(-8 * 60),
      sessionStartedAt: baseDate.addingTimeInterval(-8 * 60)
    )
  }

  static var paused: FocusSession {
    FocusSession(
      title: "Paused Focus",
      plannedDurationSeconds: 25 * 60,
      elapsedSeconds: 14 * 60,
      status: .paused,
      sessionStartedAt: baseDate.addingTimeInterval(-20 * 60)
    )
  }

  static var completed: FocusSession {
    FocusSession(
      title: "Completed Focus",
      plannedDurationSeconds: 25 * 60,
      elapsedSeconds: 25 * 60,
      status: .completed,
      sessionStartedAt: baseDate.addingTimeInterval(-30 * 60),
      completedAt: baseDate
    )
  }

  static var cancelled: FocusSession {
    FocusSession(
      title: "Cancelled Focus",
      plannedDurationSeconds: 25 * 60,
      elapsedSeconds: 5 * 60,
      status: .cancelled,
      sessionStartedAt: baseDate.addingTimeInterval(-10 * 60)
    )
  }

  static var all: [FocusSession] {
    [planned, active, paused, completed, cancelled]
  }

  static var statistics: FocusStatistics {
    FocusStatistics(
      totalFocusSeconds: 25 * 60 + 14 * 60,
      completedSessionCount: 1,
      activeSessionCount: 2,
      totalSessionCount: 5
    )
  }

  /// Timer snapshot aligned with `active` for restoration previews.
  static var activeTimerSnapshot: TimerSnapshot {
    TimerSnapshot(
      state: .running,
      configuration: .defaultFocus,
      accumulatedElapsedSeconds: 8 * 60,
      segmentStartedAt: baseDate.addingTimeInterval(-8 * 60),
      lastUpdatedAt: baseDate
    )
  }

  static var pausedTimerSnapshot: TimerSnapshot {
    TimerSnapshot(
      state: .paused,
      configuration: .defaultFocus,
      accumulatedElapsedSeconds: 14 * 60,
      segmentStartedAt: nil,
      lastUpdatedAt: baseDate
    )
  }
}
