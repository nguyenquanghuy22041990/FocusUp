//
//  ChartDayPoint.swift
//  FocusUp
//

import Foundation

struct ChartDayPoint: Identifiable, Equatable, Sendable {
  var date: Date
  var minutes: Int
  var label: String

  var id: Date { date }

  static func from(daily: [StatisticsDailyFocus], calendar: Calendar = .current) -> [ChartDayPoint] {
    daily.map {
      ChartDayPoint(
        date: $0.date,
        minutes: $0.focusMinutes,
        label: StatisticsFormatting.weekdayLabel(for: $0.date, calendar: calendar)
      )
    }
  }
}
