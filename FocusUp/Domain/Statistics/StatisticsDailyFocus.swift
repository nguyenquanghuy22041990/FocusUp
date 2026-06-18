//
//  StatisticsDailyFocus.swift
//  FocusUp
//
//  Per-day focus metrics for charts and summaries (Statistics domain).
//

import Foundation

struct StatisticsDailyFocus: Equatable, Sendable, Identifiable {
  var date: Date
  var focusMinutes: Int
  var sessionCount: Int

  var id: Date { date }

  init(date: Date, focusMinutes: Int, sessionCount: Int) {
    self.date = date
    self.focusMinutes = focusMinutes
    self.sessionCount = sessionCount
  }
}
