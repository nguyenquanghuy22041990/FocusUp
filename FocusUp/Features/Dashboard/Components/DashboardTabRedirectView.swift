//
//  DashboardTabRedirectView.swift
//  FocusUp
//

import SwiftUI

/// Redirects legacy dashboard drill-in routes to the correct production tab.
struct DashboardTabRedirectView: View {
  let tab: AppTab
  let coordinator: AppCoordinator
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ProgressView()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .task {
        coordinator.selectTab(tab)
        coordinator.popToRoot(for: tab)
        dismiss()
      }
      .accessibilityLabel("Opening \(tab.title)")
  }
}
