//
//  DashboardRoute.swift
//  FocusUp
//

import Foundation

enum DashboardRoute: String, NavigationRoute, CaseIterable {
  case weeklyOverview
  case goals
  case insights

  var id: String { rawValue }

  var title: String {
    switch self {
    case .weeklyOverview: "Weekly Overview"
    case .goals: "Goals"
    case .insights: "Insights"
    }
  }
}
