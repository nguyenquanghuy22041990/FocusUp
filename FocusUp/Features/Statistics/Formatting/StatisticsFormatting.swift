//
//  StatisticsFormatting.swift
//  FocusUp
//

import Foundation

enum StatisticsFormatting {
  static func minutesLabel(_ minutes: Int) -> String {
    minutes == 1 ? "1 minute" : "\(minutes) minutes"
  }

  static func percentLabel(_ value: Double) -> String {
    "\(Int((min(1, max(0, value)) * 100).rounded()))%"
  }

  static func weekdayLabel(for date: Date, calendar: Calendar = .current) -> String {
    let index = calendar.component(.weekday, from: date) - 1
    return calendar.shortWeekdaySymbols[index]
  }

  static func chartAccessibilitySummary(weekly: WeeklyProgress) -> String {
    let daySummaries = weekly.dailyFocus
      .filter { $0.focusMinutes > 0 }
      .map { day in
        "\(weekdayLabel(for: day.date)): \(minutesLabel(day.focusMinutes))"
      }
    if daySummaries.isEmpty {
      return "No focus time recorded this week."
    }
    return "Weekly focus chart. " + daySummaries.joined(separator: ". ") + "."
  }

  static func trendAccessibilityLabel(_ trend: ProductivityTrend) -> String {
    switch trend.direction {
    case .up:
      return "Trend up \(abs(trend.weekOverWeekPercent)) percent week over week."
    case .down:
      return "Trend down \(abs(trend.weekOverWeekPercent)) percent week over week."
    case .stable:
      return "Trend stable week over week."
    }
  }
}
