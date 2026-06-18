//
//  AppCoordinator+TabNavigation.swift
//  FocusUp
//

import Foundation

extension AppCoordinator {
  /// Opens the Focus tab. Pushes the active session route only when a session exists.
  func openFocusTab(hasActiveSession: Bool) {
    selectTab(.focus)
    if hasActiveSession {
      if !tabCoordinators.focus.path.contains(.activeSession) {
        tabCoordinators.focus.push(.activeSession)
      }
    } else {
      tabCoordinators.focus.popToRoot()
    }
  }

  /// Opens the Rest flow on the Focus tab when a rest session exists; otherwise shows setup.
  func openRestTab(hasActiveRestSession: Bool) {
    selectTab(.focus)
    if hasActiveRestSession {
      if !tabCoordinators.focus.path.contains(.restSession) {
        tabCoordinators.focus.push(.restSession)
      }
    } else {
      tabCoordinators.focus.popToRoot()
    }
  }

  /// Removes stale active-session routes when no session is running.
  func clearStaleFocusSessionRoutes(hasActiveSession: Bool) {
    guard !hasActiveSession else { return }
    tabCoordinators.focus.path.removeAll { $0 == .activeSession }
  }

  /// Removes stale rest-session routes when no rest session is running.
  func clearStaleRestSessionRoutes(hasActiveRestSession: Bool) {
    guard !hasActiveRestSession else { return }
    tabCoordinators.focus.path.removeAll { $0 == .restSession }
  }
}
