//
//  WeeklyProgress.swift
//  FocusUp
//

import Foundation

struct WeeklyProgress: Equatable, Sendable {
  var weekStart: Date
  var dailyFocus: [StatisticsDailyFocus]
  var totalMinutes: Int
  var completedSessions: Int
  var goalMinutes: Int

  var progress: Double {
    guard goalMinutes > 0 else { return 0 }
    return min(1, Double(totalMinutes) / Double(goalMinutes))
  }

  static let empty = WeeklyProgress(
    weekStart: .now,
    dailyFocus: [],
    totalMinutes: 0,
    completedSessions: 0,
    goalMinutes: StatisticsGoals.weeklyFocusMinutes
  )
}

enum StatisticsGoals {
  static let dailyFocusMinutes = 60
  static let weeklyFocusMinutes = 300
}
