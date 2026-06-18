//
//  AppDeepLink.swift
//  FocusUp
//

import Foundation

/// Typed deep-link entry points. URL parsing can be added in a later step.
enum AppDeepLink: Equatable, Sendable {
  case tab(AppTab)
  case dashboard(DashboardRoute)
  case tasks(TasksRoute)
  case focus(FocusRoute)
  case statistics(StatisticsRoute)
  case settings(SettingsRoute)
}
