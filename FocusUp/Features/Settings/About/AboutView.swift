//
//  AboutView.swift
//  FocusUp
//

import SwiftUI

struct AboutView: View {
  var body: some View {
    ResponsiveContainer {
      AppCard {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
          Label(AppMetadata.displayName, systemImage: "brain.head.profile")
            .appFont(.headline)
            .foregroundStyle(AppColors.focus)

          Text("Version \(AppMetadata.versionString)")
            .appFont(.callout)
            .foregroundStyle(AppColors.secondaryText)

          Text("FocusUp helps you work with calm focus, restorative breaks, and gentle accountability—without pressure.")
            .appFont(.body)
            .foregroundStyle(AppColors.secondaryText)
            .appMultilineText()
        }
      }
      .accessibilityElement(children: .combine)
      .accessibilityLabel("\(AppMetadata.displayName). Version \(AppMetadata.versionString)")
    }
    .navigationTitle("About")
    .navigationBarTitleDisplayMode(.inline)
  }
}
