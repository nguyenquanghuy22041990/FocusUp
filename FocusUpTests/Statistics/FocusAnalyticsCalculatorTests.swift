//
//  FocusAnalyticsCalculatorTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@Suite(.tags(.statistics))
struct FocusAnalyticsCalculatorTests {
  private var calendar: Calendar {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(secondsFromGMT: 0)!
    return cal
  }

  @Test func streakCountsConsecutiveDays() {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let today = calendar.startOfDay(for: now)
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

    var todaySession = DomainFixtures.focusSession(status: .completed)
    todaySession.completedAt = today.addingTimeInterval(1_000)
    var yesterdaySession = DomainFixtures.focusSession(status: .completed)
    yesterdaySession.completedAt = yesterday.addingTimeInterval(1_000)

    let streak = FocusAnalyticsCalculator.streakStatistics(
      sessions: [todaySession, yesterdaySession],
      now: now,
      calendar: calendar
    )
    #expect(streak.currentStreakDays == 2)
    #expect(streak.longestStreakDays == 2)
  }

  @Test func productivityTrendDetectsIncrease() {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)!.start
    let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: weekStart)!

    var thisWeekSession = DomainFixtures.focusSession(status: .completed, elapsedSeconds: 3_600)
    thisWeekSession.completedAt = weekStart.addingTimeInterval(3_600)
    var lastWeekSession = DomainFixtures.focusSession(status: .completed, elapsedSeconds: 1_800)
    lastWeekSession.completedAt = lastWeek.addingTimeInterval(3_600)

    let trend = FocusAnalyticsCalculator.productivityTrend(
      sessions: [thisWeekSession, lastWeekSession],
      now: now,
      calendar: calendar
    )
    #expect(trend.direction == .up)
    #expect(trend.weekOverWeekPercent > 0)
  }

  @Test func weeklyProgressBuildsSevenDays() {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let weekly = FocusAnalyticsCalculator.weeklyProgress(
      sessions: [],
      now: now,
      calendar: calendar
    )
    #expect(weekly.dailyFocus.count == 7)
  }

  @Test func chartPointsMapFromDailyFocus() {
    let day = StatisticsDailyFocus(date: .now, focusMinutes: 30, sessionCount: 1)
    let points = ChartDayPoint.from(daily: [day])
    #expect(points.count == 1)
    #expect(points.first?.minutes == 30)
  }
}
