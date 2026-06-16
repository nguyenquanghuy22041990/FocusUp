//
//  PersistedNavigationState.swift
//  FocusUp
//

import Foundation

/// Codable snapshot of navigation state for SceneStorage restoration.
struct PersistedNavigationState: Codable, Equatable, Sendable {
  var selectedTab: AppTab
  var dashboardPath: [DashboardRoute]
  var tasksPath: [TasksRoute]
  var focusPath: [FocusRoute]
  var statisticsPath: [StatisticsRoute]
  var settingsPath: [SettingsRoute]

  static let empty = PersistedNavigationState(
    selectedTab: .dashboard,
    dashboardPath: [],
    tasksPath: [],
    focusPath: [],
    statisticsPath: [],
    settingsPath: []
  )
}
