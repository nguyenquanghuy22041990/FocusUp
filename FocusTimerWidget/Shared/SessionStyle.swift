//
//  SessionStyle.swift
//  FocusTimerWidget
//

import SwiftUI

enum SessionStyle {
  static func accentColor(for type: SessionLiveActivityType) -> Color {
    switch type {
    case .focus: Color.orange
    case .rest: Color.mint
    }
  }

  static func stateLabel(_ state: LiveActivitySessionState) -> String {
    switch state {
    case .running: "Running"
    case .paused: "Paused"
    case .completed: "Complete"
    }
  }
}

enum WidgetTimerFormatting {
  static func compactClock(seconds: Int) -> String {
    let minutes = seconds / 60
    let secs = seconds % 60
    return String(format: "%d:%02d", minutes, secs)
  }

  static func minimalLabel(seconds: Int) -> String {
    let minutes = max(1, (seconds + 59) / 60)
    return "\(minutes)m"
  }

  static func pausedClock(seconds: Int) -> String {
    compactClock(seconds: seconds)
  }

  static func shortTimeRange(start: Date, end: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return "\(formatter.string(from: start)) – \(formatter.string(from: end))"
  }
}
