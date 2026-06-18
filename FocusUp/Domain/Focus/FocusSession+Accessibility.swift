//
//  FocusSession+Accessibility.swift
//  FocusUp
//

import Foundation

extension FocusSession {
  /// VoiceOver-friendly elapsed description at a point in time.
  func accessibilityElapsedDescription(at date: Date = .now) -> String {
    let minutes = elapsedSeconds(at: date) / 60
    let seconds = elapsedSeconds(at: date) % 60
    return "\(minutes) minutes \(seconds) seconds elapsed"
  }

  func accessibilityRemainingDescription(at date: Date = .now) -> String {
    let remaining = remainingSeconds(at: date)
    let minutes = remaining / 60
    let seconds = remaining % 60
    return "\(minutes) minutes \(seconds) seconds remaining"
  }

  var accessibilityStatusLabel: String {
    switch status {
    case .planned: "Planned"
    case .active: "Running"
    case .paused: "Paused"
    case .completed: "Completed"
    case .cancelled: "Cancelled"
    }
  }
}
