//
//  MockNavigationState.swift
//  FocusUp
//

import Foundation

enum MockNavigationStateFactory {
  static var dashboardDetail: PersistedNavigationState {
    PersistedNavigationState(
      selectedTab: .dashboard,
      dashboardPath: [.insights],
      tasksPath: [],
      focusPath: [],
      statisticsPath: [],
      settingsPath: []
    )
  }

  @MainActor
  static func coordinator(matching state: PersistedNavigationState) -> AppCoordinator {
    let coordinator = AppCoordinator(selectedTab: state.selectedTab)
    coordinator.applyRestorationState(state)
    return coordinator
  }
}
