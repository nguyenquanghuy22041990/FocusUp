//
//  AdaptiveRootNavigationView.swift
//  FocusUp
//

import SwiftUI

/// Compact: TabView + per-tab NavigationStack. Regular: sidebar + detail NavigationStack.
struct AdaptiveRootNavigationView: View {
  @Environment(\.appContainer) private var container
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.focusMotionReduced) private var motionReduced
  @Bindable var coordinator: AppCoordinator
  @State private var splitColumnVisibility = NavigationSplitViewVisibility.automatic

  private var isImmersiveTimerActive: Bool {
    ActiveTimerTabBarVisibility.isImmersiveModeActive(
      focusManager: container.focusSessionManager,
      restManager: container.restSessionManager
    )
  }

  var body: some View {
    Group {
      if horizontalSizeClass == .regular {
        regularLayout
      } else {
        compactLayout
      }
    }
    .onAppear(perform: syncSplitViewVisibility)
    .onChange(of: container.coordinator.hasCompletedColdRestore) { _, isComplete in
      guard isComplete else { return }
      syncSplitViewVisibility()
    }
    .onChange(of: isImmersiveTimerActive) { _, _ in
      syncSplitViewVisibility()
    }
  }

  private var compactLayout: some View {
    TabView(selection: $coordinator.selectedTab) {
      ForEach(AppTab.allCases) { tab in
        TabFeatureRoot(tab: tab)
          .tabItem {
            Label(tab.title, systemImage: tab.systemImage)
          }
          .tag(tab)
          .accessibilityLabel(tab.accessibilityLabel)
      }
    }
    .toolbar(isImmersiveTimerActive ? .hidden : .automatic, for: .tabBar)
  }

  private var regularLayout: some View {
    NavigationSplitView(columnVisibility: $splitColumnVisibility) {
      AppSidebarView(coordinator: coordinator)
    } detail: {
      TabFeatureRoot(tab: coordinator.selectedTab)
    }
    .animation(FocusMotion.animation(reduced: motionReduced, style: .navigation), value: splitColumnVisibility)
  }

  private func syncSplitViewVisibility() {
    splitColumnVisibility = ActiveTimerTabBarVisibility.splitViewVisibility(
      focusManager: container.focusSessionManager,
      restManager: container.restSessionManager
    )
  }
}

#Preview("Compact") {
  AdaptiveRootNavigationView(coordinator: .preview)
    .appContainer(.preview)
}

#Preview("Regular") {
  AdaptiveRootNavigationView(coordinator: .preview)
    .appContainer(.preview)
    .environment(\.horizontalSizeClass, .regular)
}
