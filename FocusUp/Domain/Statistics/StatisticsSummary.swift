//
//  StatisticsSummary.swift
//  FocusUp
//

import Foundation

struct StatisticsSummary: Equatable, Sendable {
  var weeklyProgress: WeeklyProgress
  var streak: StreakStatistics
  var trend: ProductivityTrend
  var completionRate: Double
  var completedTasksCount: Int
  var trackableTasksCount: Int
  var totalFocusMinutes: Int
  var totalCompletedSessions: Int
  var averageSessionMinutes: Int
  var focusDistribution: [FocusDistributionBucket]

  static let empty = StatisticsSummary(
    weeklyProgress: .empty,
    streak: .empty,
    trend: .empty,
    completionRate: 0,
    completedTasksCount: 0,
    trackableTasksCount: 0,
    totalFocusMinutes: 0,
    totalCompletedSessions: 0,
    averageSessionMinutes: 0,
    focusDistribution: []
  )
}

struct FocusDistributionBucket: Equatable, Sendable, Identifiable {
  var label: String
  var minutes: Int
  var proportion: Double

  var id: String { label }
}
