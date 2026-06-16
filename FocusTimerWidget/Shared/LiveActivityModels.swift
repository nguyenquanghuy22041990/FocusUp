//
//  LiveActivityModels.swift
//  FocusTimerWidget
//
//  Keep in sync with FocusUp/Features/LiveActivities/Models/
//

import ActivityKit
import Foundation

enum SessionLiveActivityType: String, Codable, Hashable, Sendable {
  case focus
  case rest

  var displayName: String {
    switch self {
    case .focus: "Focus Session"
    case .rest: "Rest Break"
    }
  }

  var compactIcon: String {
    switch self {
    case .focus: "🍅"
    case .rest: "☕️"
    }
  }

  var defaultMotivation: String {
    switch self {
    case .focus: "Stay focused."
    case .rest: "Breathe and recover."
    }
  }
}

enum LiveActivitySessionState: String, Codable, Hashable, Sendable {
  case running
  case paused
  case completed
}

struct FocusSessionAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable, Sendable {
    var endDate: Date?
    var pausedRemainingSeconds: Int?
    var sessionState: LiveActivitySessionState
    var progress: Double
    var motivationalMessage: String
  }

  var sessionType: SessionLiveActivityType
  var sessionTitle: String
  var sessionID: UUID
  var startDate: Date
  var totalDurationSeconds: Int

  var plannedEndDate: Date {
    startDate.addingTimeInterval(TimeInterval(totalDurationSeconds))
  }
}
