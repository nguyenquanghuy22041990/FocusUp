//
//  SessionLiveActivityType.swift
//  FocusUp
//

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
