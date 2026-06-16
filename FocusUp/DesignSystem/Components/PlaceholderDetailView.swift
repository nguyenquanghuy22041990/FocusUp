//
//  PlaceholderDetailView.swift
//  FocusUp
//

import SwiftUI

struct PlaceholderDetailView: View {
  let title: String
  let subtitle: String
  let systemImage: String

  var body: some View {
    ResponsiveContainer {
      VStack(alignment: .leading, spacing: AppSpacing.lg) {
        Label(title, systemImage: systemImage)
          .font(AppTypography.title())
          .foregroundStyle(AppColors.primaryText)
          .accessibilityAddTraits(.isHeader)

        Text(subtitle)
          .font(AppTypography.body())
          .foregroundStyle(AppColors.secondaryText)

        Text("Detail placeholder — production content will replace this screen.")
          .font(AppTypography.callout())
          .foregroundStyle(AppColors.secondaryText)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
  }
}
