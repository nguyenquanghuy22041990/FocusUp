//
//  TabCoordinators.swift
//  FocusUp
//

import Observation

/// Aggregates per-tab coordinators for restoration and deep-link handling.
@MainActor
struct TabCoordinators {
  var dashboard: TabCoordinator<DashboardRoute>
  var tasks: TabCoordinator<TasksRoute>
  var focus: TabCoordinator<FocusRoute>
  var statistics: TabCoordinator<StatisticsRoute>
  var settings: TabCoordinator<SettingsRoute>

  init(
    dashboard: TabCoordinator<DashboardRoute>,
    tasks: TabCoordinator<TasksRoute>,
    focus: TabCoordinator<FocusRoute>,
    statistics: TabCoordinator<StatisticsRoute>,
    settings: TabCoordinator<SettingsRoute>
  ) {
    self.dashboard = dashboard
    self.tasks = tasks
    self.focus = focus
    self.statistics = statistics
    self.settings = settings
  }

  init() {
    self.dashboard = TabCoordinator()
    self.tasks = TabCoordinator()
    self.focus = TabCoordinator()
    self.statistics = TabCoordinator()
    self.settings = TabCoordinator()
  }

  mutating func popAllToRoot() {
    dashboard.popToRoot()
    tasks.popToRoot()
    focus.popToRoot()
    statistics.popToRoot()
    settings.popToRoot()
  }
}
