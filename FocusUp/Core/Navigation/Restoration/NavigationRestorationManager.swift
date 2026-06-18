//
//  NavigationRestorationManager.swift
//  FocusUp
//

import Foundation

/// Encodes and decodes navigation snapshots for SceneStorage.
enum NavigationRestorationManager {
  private static let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    return encoder
  }()

  private static let decoder = JSONDecoder()

  static func encode(_ state: PersistedNavigationState) -> Data? {
    try? encoder.encode(state)
  }

  static func decode(_ data: Data?) -> PersistedNavigationState? {
    guard let data, !data.isEmpty else { return nil }
    return try? decoder.decode(PersistedNavigationState.self, from: data)
  }
}

// MARK: - Coordinator bridging

extension AppCoordinator {
  func exportRestorationState() -> PersistedNavigationState {
    PersistedNavigationState(
      selectedTab: selectedTab,
      dashboardPath: tabCoordinators.dashboard.path,
      tasksPath: tabCoordinators.tasks.path,
      focusPath: tabCoordinators.focus.path,
      statisticsPath: tabCoordinators.statistics.path,
      settingsPath: tabCoordinators.settings.path
    )
  }

  func applyRestorationState(_ state: PersistedNavigationState) {
    selectedTab = state.selectedTab
    tabCoordinators.dashboard.setPath(state.dashboardPath)
    tabCoordinators.tasks.setPath(state.tasksPath)
    tabCoordinators.focus.setPath(state.focusPath)
    tabCoordinators.statistics.setPath(state.statisticsPath)
    tabCoordinators.settings.setPath(state.settingsPath)
  }
}
