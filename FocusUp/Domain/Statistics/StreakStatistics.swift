//
//  StreakStatistics.swift
//  FocusUp
//

import Foundation

struct StreakStatistics: Equatable, Sendable {
  var currentStreakDays: Int
  var longestStreakDays: Int
  var lastFocusDate: Date?

  static let empty = StreakStatistics(
    currentStreakDays: 0,
    longestStreakDays: 0,
    lastFocusDate: nil
  )
}
