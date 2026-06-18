//
//  AppearanceSettingsView.swift
//  FocusUp
//

import SwiftUI

struct AppearanceSettingsView: View {
  var body: some View {
    ResponsiveContainer {
      AppCard {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
          Label("Appearance", systemImage: "circle.lefthalf.filled")
            .appFont(.headline)

          Text("FocusUp follows your system light and dark mode. Reduce Motion and Dynamic Type from iOS Settings are respected throughout the app.")
            .appFont(.body)
            .foregroundStyle(AppColors.secondaryText)
            .appMultilineText()
        }
      }
      .accessibilityElement(children: .combine)
    }
    .navigationTitle("Appearance")
    .navigationBarTitleDisplayMode(.inline)
  }
}
