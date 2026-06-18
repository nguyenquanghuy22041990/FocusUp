//
//  StatisticsPreviewData.swift
//  FocusUp
//

import Foundation

enum StatisticsPreviewData {
  static var populated: StatisticsSummary {
    var calendar = Calendar.current
    calendar.timeZone = .current
    let weekStart = calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now

    let daily: [StatisticsDailyFocus] = (0..<7).compactMap { offset in
      guard let date = calendar.date(byAdding: .day, value: offset, to: weekStart) else { return nil }
      let minutes = [0, 25, 40, 15, 55, 30, 20][offset]
      return StatisticsDailyFocus(
        date: calendar.startOfDay(for: date),
        focusMinutes: minutes,
        sessionCount: minutes > 0 ? 1 : 0
      )
    }

    return StatisticsSummary(
      weeklyProgress: WeeklyProgress(
        weekStart: weekStart,
        dailyFocus: daily,
        totalMinutes: daily.reduce(0) { $0 + $1.focusMinutes },
        completedSessions: 6,
        goalMinutes: StatisticsGoals.weeklyFocusMinutes
      ),
      streak: StreakStatistics(
        currentStreakDays: 4,
        longestStreakDays: 9,
        lastFocusDate: .now
      ),
      trend: ProductivityTrend(
        direction: .up,
        weekOverWeekPercent: 18,
        insight: "Focus time is up 18% this week—a steady, sustainable climb."
      ),
      completionRate: 0.6,
      completedTasksCount: 3,
      trackableTasksCount: 5,
      totalFocusMinutes: 185,
      totalCompletedSessions: 12,
      averageSessionMinutes: 25,
      focusDistribution: [
        FocusDistributionBucket(label: "Mon", minutes: 40, proportion: 0.3),
        FocusDistributionBucket(label: "Wed", minutes: 35, proportion: 0.26),
        FocusDistributionBucket(label: "Fri", minutes: 30, proportion: 0.22),
      ]
    )
  }

  static var empty: StatisticsSummary {
    .empty
  }
}
