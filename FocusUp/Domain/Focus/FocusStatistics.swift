//
//  FocusStatistics.swift
//  FocusUp
//

import Foundation

struct FocusStatistics: Codable, Equatable, Sendable {
  var totalFocusSeconds: Int
  var completedSessionCount: Int
  var activeSessionCount: Int
  var totalSessionCount: Int

  init(
    totalFocusSeconds: Int = 0,
    completedSessionCount: Int = 0,
    activeSessionCount: Int = 0,
    totalSessionCount: Int = 0
  ) {
    self.totalFocusSeconds = totalFocusSeconds
    self.completedSessionCount = completedSessionCount
    self.activeSessionCount = activeSessionCount
    self.totalSessionCount = totalSessionCount
  }
}
