//
//  StatisticsAccessibilityTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

struct StatisticsAccessibilityTests {
  @Test(.tags(.statistics, .production))
  func chartSummaryIncludesDaysWithFocus() {
    var calendar = Calendar.current
    let weekStart = calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
    let daily = [
      StatisticsDailyFocus(
        date: calendar.startOfDay(for: weekStart),
        focusMinutes: 25,
        sessionCount: 1
      )
    ]
    let weekly = WeeklyProgress(
      weekStart: weekStart,
      dailyFocus: daily,
      totalMinutes: 25,
      completedSessions: 1,
      goalMinutes: StatisticsGoals.weeklyFocusMinutes
    )

    let summary = StatisticsFormatting.chartAccessibilitySummary(weekly: weekly)

    #expect(summary.contains("Weekly focus chart"))
    #expect(summary.contains("25 minutes") || summary.contains("minute"))
  }

  @Test(.tags(.statistics, .production))
  func chartSummaryHandlesEmptyWeek() {
    let summary = StatisticsFormatting.chartAccessibilitySummary(weekly: .empty)
    #expect(summary == "No focus time recorded this week.")
  }
}
