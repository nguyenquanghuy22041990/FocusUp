//
//  TabFeatureRoot.swift
//  FocusUp
//

import SwiftUI

/// Selects the feature root view for a tab without device-specific branching.
struct TabFeatureRoot: View {
  let tab: AppTab

  var body: some View {
    switch tab {
    case .dashboard:
      DashboardView()
    case .tasks:
      TasksView()
    case .focus:
      FocusView()
    case .statistics:
      StatisticsView()
    case .settings:
      SettingsView()
    }
  }
}
