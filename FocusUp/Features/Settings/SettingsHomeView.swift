//
//  SettingsHomeView.swift
//  FocusUp
//

import SwiftUI

struct SettingsHomeView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  var body: some View {
    ResponsiveContainer(wide: horizontalSizeClass == .regular) {
      VStack(alignment: .leading, spacing: AdaptiveSpacing.sectionSpacing(horizontalSizeClass: horizontalSizeClass)) {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
          AppTextStyles.screenTitle("Settings")
          AppTextStyles.screenSubtitle("Notifications, appearance, and app information.")
        }
        .accessibilityElement(children: .combine)

        VStack(alignment: .leading, spacing: AppSpacing.sm) {
          Text("Preferences")
            .appFont(.headline)
            .accessibilityAddTraits(.isHeader)

          NavigationLink(value: SettingsRoute.notifications) {
            settingsRow(title: SettingsRoute.notifications.title, systemImage: "bell.fill")
          }

          NavigationLink(value: SettingsRoute.appearance) {
            settingsRow(title: SettingsRoute.appearance.title, systemImage: "circle.lefthalf.filled")
          }

          NavigationLink(value: SettingsRoute.about) {
            settingsRow(title: SettingsRoute.about.title, systemImage: "info.circle")
          }
        }
      }
    }
    .navigationTitle("Settings")
    .navigationBarTitleDisplayMode(.large)
  }

  private func settingsRow(title: String, systemImage: String) -> some View {
    Label(title, systemImage: systemImage)
      .appFont(.body)
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(minHeight: AppSpacing.minimumTouchTarget)
  }
}
