//
//  RestSession+Accessibility.swift
//  FocusUp
//

import Foundation

extension RestSession {
  func accessibilityElapsedDescription(at date: Date = .now) -> String {
    let total = elapsedSeconds(at: date)
    return "\(total / 60) minutes \(total % 60) seconds rested"
  }

  func accessibilityRemainingDescription(at date: Date = .now) -> String {
    let remaining = remainingSeconds(at: date)
    return "\(remaining / 60) minutes \(remaining % 60) seconds remaining"
  }

  var accessibilityStatusLabel: String {
    switch status {
    case .planned: "Ready to rest"
    case .active: "Resting"
    case .paused: "Rest paused"
    case .completed: "Rest complete"
    case .cancelled: "Rest ended"
    }
  }
}
