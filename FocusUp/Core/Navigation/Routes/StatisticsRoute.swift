//
//  StatisticsRoute.swift
//  FocusUp
//

import Foundation

enum StatisticsRoute: String, NavigationRoute, CaseIterable {
  case weeklyChart
  case progress
  case streaks

  var id: String { rawValue }

  var title: String {
    switch self {
    case .weeklyChart: "Weekly Chart"
    case .progress: "Progress"
    case .streaks: "Streaks"
    }
  }
}
