//
//  ActiveTimerTabBarVisibility.swift
//  FocusUp
//

import SwiftUI

enum ActiveTimerTabBarVisibility {
  @MainActor
  static func isImmersiveModeActive(
    focusManager: FocusSessionManager,
    restManager: RestSessionManager
  ) -> Bool {
    let focusActive = focusManager.activeSession?.status.isActiveLifecycle ?? false
    let restActive = restManager.activeSession?.status.isActiveLifecycle ?? false
    return focusActive || restActive
  }

  @MainActor
  static func shouldHideTabBar(
    focusManager: FocusSessionManager,
    restManager: RestSessionManager
  ) -> Bool {
    isImmersiveModeActive(focusManager: focusManager, restManager: restManager)
  }

  @MainActor
  static func splitViewVisibility(
    focusManager: FocusSessionManager,
    restManager: RestSessionManager
  ) -> NavigationSplitViewVisibility {
    isImmersiveModeActive(focusManager: focusManager, restManager: restManager)
      ? .detailOnly
      : .automatic
  }
}

struct ActiveTimerTabBarModifier: ViewModifier {
  @Environment(\.appContainer) private var container

  private var shouldHide: Bool {
    ActiveTimerTabBarVisibility.isImmersiveModeActive(
      focusManager: container.focusSessionManager,
      restManager: container.restSessionManager
    )
  }

  func body(content: Content) -> some View {
    content.toolbar(shouldHide ? .hidden : .automatic, for: .tabBar)
  }
}

extension View {
  func hidesTabBarForActiveTimer() -> some View {
    modifier(ActiveTimerTabBarModifier())
  }
}
