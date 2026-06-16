//
//  AppForegroundRefresh.swift
//  FocusUp
//

import Foundation

/// Lightweight foreground refresh — keeps notifications and session state aligned after interruption.
enum AppForegroundRefresh {
  @MainActor
  static func perform(using container: AppContainer) async {
    await container.notificationScheduler.rescheduleAll()
    container.coordinator.clearStaleFocusSessionRoutes(
      hasActiveSession: container.focusSessionManager.activeSession?.status.isActiveLifecycle == true
    )
    container.coordinator.clearStaleRestSessionRoutes(
      hasActiveRestSession: container.restSessionManager.activeSession?.status.isActiveLifecycle == true
    )
    await dismissLiveActivitiesWhenNoActiveSession(using: container)
  }

  @MainActor
  static func dismissLiveActivitiesWhenNoActiveSession(using container: AppContainer) async {
    let hasFocus = container.focusSessionManager.activeSession?.status.isActiveLifecycle == true
    let hasRest = container.restSessionManager.activeSession?.status.isActiveLifecycle == true
    guard !hasFocus, !hasRest else { return }
    await container.liveActivityManager.end(immediate: true)
  }
}
