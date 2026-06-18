//
//  AppCoordinator+RestorationReconciliation.swift
//  FocusUp
//

import Foundation

extension AppCoordinator {
  /// Aligns restored navigation paths with live session managers after cold restore.
  func reconcileNavigationWithSessions(
    focusManager: FocusSessionManager,
    restManager: RestSessionManager
  ) {
    let hasFocus = focusManager.activeSession?.status.isActiveLifecycle == true
    let hasRest = restManager.activeSession?.status.isActiveLifecycle == true

    if hasFocus {
      if selectedTab == .focus, !tabCoordinators.focus.path.contains(.activeSession) {
        tabCoordinators.focus.push(.activeSession)
      }
    } else {
      clearStaleFocusSessionRoutes(hasActiveSession: false)
    }

    if hasRest {
      if selectedTab == .focus, !tabCoordinators.focus.path.contains(.restSession) {
        tabCoordinators.focus.push(.restSession)
      }
    } else {
      clearStaleRestSessionRoutes(hasActiveRestSession: false)
    }
  }
}
