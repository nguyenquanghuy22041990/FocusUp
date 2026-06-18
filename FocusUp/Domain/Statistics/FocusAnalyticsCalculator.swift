//
//  FocusAnalyticsCalculator.swift
//  FocusUp
//
//  Shared lightweight analytics — used by StatisticsRepository and Dashboard.
//

import Foundation

enum FocusAnalyticsCalculator {
  // MARK: - Full summary

  static func buildStatisticsSummary(
    completedSessions: [FocusSession],
    tasks: [Task],
    now: Date = .now,
    calendar: Calendar = .current
  ) -> StatisticsSummary {
    let weekly = weeklyProgress(
      sessions: completedSessions,
      now: now,
      calendar: calendar
    )
    let streak = streakStatistics(
      sessions: completedSessions,
      now: now,
      calendar: calendar
    )
    let trend = productivityTrend(
      sessions: completedSessions,
      now: now,
      calendar: calendar
    )
    let completion = taskCompletionRate(tasks: tasks)
    let totalMinutes = completedSessions.reduce(0) { $0 + $1.elapsedSeconds } / 60
    let average = completedSessions.isEmpty
      ? 0
      : totalMinutes / completedSessions.count
    let distribution = focusDistributionByWeekday(
      sessions: completedSessions,
      calendar: calendar
    )

    return StatisticsSummary(
      weeklyProgress: weekly,
      streak: streak,
      trend: trend,
      completionRate: completion.rate,
      completedTasksCount: completion.completedCount,
      trackableTasksCount: completion.trackableCount,
      totalFocusMinutes: totalMinutes,
      totalCompletedSessions: completedSessions.count,
      averageSessionMinutes: average,
      focusDistribution: distribution
    )
  }

  static func focusStatisticsSummary(
    from summary: StatisticsSummary
  ) -> FocusStatisticsSummary {
    FocusStatisticsSummary(
      totalFocusMinutes: summary.totalFocusMinutes,
      completedSessionsCount: summary.totalCompletedSessions,
      currentStreakDays: summary.streak.currentStreakDays,
      weekStartDate: summary.weeklyProgress.weekStart
    )
  }

  // MARK: - Weekly

  static func weeklyProgress(
    sessions: [FocusSession],
    now: Date = .now,
    calendar: Calendar = .current
  ) -> WeeklyProgress {
    let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? calendar.startOfDay(for: now)
    let days = (0..<7).compactMap { offset -> StatisticsDailyFocus? in
      guard let day = calendar.date(byAdding: .day, value: offset, to: weekStart) else { return nil }
      let dayStart = calendar.startOfDay(for: day)
      let daySessions = sessions.filter { session in
        let anchor = session.completedAt ?? session.updatedAt
        return calendar.isDate(anchor, inSameDayAs: dayStart)
      }
      let seconds = daySessions.reduce(0) { $0 + $1.elapsedSeconds }
      return StatisticsDailyFocus(
        date: dayStart,
        focusMinutes: seconds / 60,
        sessionCount: daySessions.count
      )
    }

    let totalMinutes = days.reduce(0) { $0 + $1.focusMinutes }
    let sessionCount = sessions.filter { session in
      let anchor = session.completedAt ?? session.updatedAt
      guard let interval = calendar.dateInterval(of: .weekOfYear, for: now) else { return false }
      return interval.contains(anchor)
    }.count

    return WeeklyProgress(
      weekStart: weekStart,
      dailyFocus: days,
      totalMinutes: totalMinutes,
      completedSessions: sessionCount,
      goalMinutes: StatisticsGoals.weeklyFocusMinutes
    )
  }

  // MARK: - Streak

  static func streakStatistics(
    sessions: [FocusSession],
    now: Date = .now,
    calendar: Calendar = .current
  ) -> StreakStatistics {
    let completionDays = sessions.compactMap { session -> Date? in
      guard let completedAt = session.completedAt else { return nil }
      return calendar.startOfDay(for: completedAt)
    }.sorted()

    guard !completionDays.isEmpty else {
      return .empty
    }

    let uniqueDays = Array(Set(completionDays)).sorted()
    let current = currentStreakDays(from: uniqueDays, now: now, calendar: calendar)
    let longest = longestStreakDays(from: uniqueDays, calendar: calendar)

    return StreakStatistics(
      currentStreakDays: current,
      longestStreakDays: longest,
      lastFocusDate: uniqueDays.last
    )
  }

  static func currentStreakDays(
    sessions: [FocusSession],
    now: Date = .now,
    calendar: Calendar = .current
  ) -> Int {
    let days = Set(
      sessions.compactMap { session -> Date? in
        guard let completedAt = session.completedAt else { return nil }
        return calendar.startOfDay(for: completedAt)
      }
    )
    return currentStreakDays(from: Array(days).sorted(), now: now, calendar: calendar)
  }

  private static func currentStreakDays(
    from sortedUniqueDays: [Date],
    now: Date,
    calendar: Calendar
  ) -> Int {
    guard !sortedUniqueDays.isEmpty else { return 0 }

    var streak = 0
    var cursor = calendar.startOfDay(for: now)

    if !sortedUniqueDays.contains(cursor) {
      guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) else { return 0 }
      cursor = yesterday
    }

    while sortedUniqueDays.contains(cursor) {
      streak += 1
      guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
      cursor = previous
    }
    return streak
  }

  private static func longestStreakDays(
    from sortedUniqueDays: [Date],
    calendar: Calendar
  ) -> Int {
    guard !sortedUniqueDays.isEmpty else { return 0 }
    var longest = 1
    var current = 1

    for index in 1..<sortedUniqueDays.count {
      let previous = sortedUniqueDays[index - 1]
      let day = sortedUniqueDays[index]
      if let next = calendar.date(byAdding: .day, value: 1, to: previous),
         calendar.isDate(next, inSameDayAs: day) {
        current += 1
        longest = max(longest, current)
      } else {
        current = 1
      }
    }
    return longest
  }

  // MARK: - Trend

  static func productivityTrend(
    sessions: [FocusSession],
    now: Date = .now,
    calendar: Calendar = .current
  ) -> ProductivityTrend {
    let thisWeek = minutesInWeekContaining(date: now, sessions: sessions, calendar: calendar)
    let lastWeekAnchor = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
    let lastWeek = minutesInWeekContaining(date: lastWeekAnchor, sessions: sessions, calendar: calendar)

    let percent: Int
    if lastWeek == 0 {
      percent = thisWeek > 0 ? 100 : 0
    } else {
      percent = Int(((Double(thisWeek - lastWeek) / Double(lastWeek)) * 100).rounded())
    }

    let direction: ProductivityTrend.Direction
    if percent > 5 { direction = .up }
    else if percent < -5 { direction = .down }
    else { direction = .stable }

    let insight = trendInsight(
      direction: direction,
      percent: percent,
      thisWeekMinutes: thisWeek
    )

    return ProductivityTrend(
      direction: direction,
      weekOverWeekPercent: percent,
      insight: insight
    )
  }

  private static func minutesInWeekContaining(
    date: Date,
    sessions: [FocusSession],
    calendar: Calendar
  ) -> Int {
    guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else { return 0 }
    let seconds = sessions
      .filter { session in
        let anchor = session.completedAt ?? session.updatedAt
        return interval.contains(anchor)
      }
      .reduce(0) { $0 + $1.elapsedSeconds }
    return seconds / 60
  }

  private static func trendInsight(
    direction: ProductivityTrend.Direction,
    percent: Int,
    thisWeekMinutes: Int
  ) -> String {
    switch direction {
    case .up:
      return "Focus time is up \(abs(percent))% this week—a steady, sustainable climb."
    case .down:
      return "This week is lighter than last. Rest counts; return when you're ready."
    case .stable:
      if thisWeekMinutes == 0 {
        return "Your rhythm is open this week. One session can set a calm tone."
      }
      return "Your focus rhythm is holding steady. Consistency matters more than spikes."
    }
  }

  // MARK: - Tasks

  static func taskCompletionRate(tasks: [Task]) -> (rate: Double, completedCount: Int, trackableCount: Int) {
    let trackable = tasks.filter { $0.status != .archived }
    guard !trackable.isEmpty else { return (0, 0, 0) }
    let completed = trackable.filter(\.isCompleted).count
    return (
      Double(completed) / Double(trackable.count),
      completed,
      trackable.count
    )
  }

  // MARK: - Distribution

  static func focusDistributionByWeekday(
    sessions: [FocusSession],
    calendar: Calendar = .current
  ) -> [FocusDistributionBucket] {
    var minutesByLabel: [String: Int] = [:]

    for session in sessions {
      let anchor = session.completedAt ?? session.updatedAt
      let weekday = calendar.component(.weekday, from: anchor)
      let label = calendar.shortWeekdaySymbols[weekday - 1]
      minutesByLabel[label, default: 0] += session.elapsedSeconds / 60
    }

    let total = minutesByLabel.values.reduce(0, +)
    guard total > 0 else { return [] }

    return minutesByLabel
      .sorted { $0.value > $1.value }
      .map { label, minutes in
        FocusDistributionBucket(
          label: label,
          minutes: minutes,
          proportion: Double(minutes) / Double(total)
        )
      }
  }
}
