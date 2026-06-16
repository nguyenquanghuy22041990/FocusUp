//
//  ProgressCalculator.swift
//  FocusUp
//

import Foundation

enum ProgressCalculator {
  static func progress(
    totalDurationSeconds: Int,
    endDate: Date?,
    pausedRemainingSeconds: Int?,
    now: Date = .now
  ) -> Double {
    guard totalDurationSeconds > 0 else { return 0 }

    if let pausedRemainingSeconds {
      let elapsed = totalDurationSeconds - pausedRemainingSeconds
      return min(1, max(0, Double(elapsed) / Double(totalDurationSeconds)))
    }

    guard let endDate else { return 0 }
    let remaining = max(0, endDate.timeIntervalSince(now))
    let elapsed = Double(totalDurationSeconds) - remaining
    return min(1, max(0, elapsed / Double(totalDurationSeconds)))
  }

  static func endDate(
    remainingSeconds: Int,
    from date: Date = .now
  ) -> Date {
    date.addingTimeInterval(TimeInterval(max(0, remainingSeconds)))
  }
}
