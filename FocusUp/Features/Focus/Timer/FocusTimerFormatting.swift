//
//  FocusTimerFormatting.swift
//  FocusUp
//

import Foundation

enum FocusTimerFormatting {
  static func remainingLabel(seconds: Int) -> String {
    let clamped = max(0, seconds)
    let minutes = clamped / 60
    let remainder = clamped % 60
    return String(format: "%d:%02d", minutes, remainder)
  }

  static func durationLabel(seconds: Int) -> String {
    let minutes = max(0, seconds) / 60
    return minutes == 1 ? "1 minute" : "\(minutes) minutes"
  }
}
