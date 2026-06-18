//
//  FocusStatisticsSummary.swift
//  FocusUp
//

import Foundation

struct FocusStatisticsSummary: Codable, Equatable, Sendable {
  var totalFocusMinutes: Int
  var completedSessionsCount: Int
  var currentStreakDays: Int
  var weekStartDate: Date

  init(
    totalFocusMinutes: Int = 0,
    completedSessionsCount: Int = 0,
    currentStreakDays: Int = 0,
    weekStartDate: Date = .now
  ) {
    self.totalFocusMinutes = totalFocusMinutes
    self.completedSessionsCount = completedSessionsCount
    self.currentStreakDays = currentStreakDays
    self.weekStartDate = weekStartDate
  }
}
