//
//  FocusSessionAttributes.swift
//  FocusUp
//
//  Shared with FocusTimerWidget extension — keep schema in sync.
//

import Foundation

#if canImport(ActivityKit)
import ActivityKit

struct FocusSessionAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable, Sendable {
    /// When set, Lock Screen / Dynamic Island use system countdown rendering.
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
}
#endif
