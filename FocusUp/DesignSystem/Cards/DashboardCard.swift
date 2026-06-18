//
//  DashboardCard.swift
//  FocusUp
//

import SwiftUI

struct DashboardCard: View {
  let title: String
  let value: String
  let subtitle: String
  let systemImage: String

  var body: some View {
    AppCard {
      VStack(alignment: .leading, spacing: AppSpacing.sm) {
        Label(title, systemImage: systemImage)
          .appFont(.headline)
          .foregroundStyle(AppColors.focus)

        Text(value)
          .appFont(.largeTitle)
          .foregroundStyle(AppColors.primaryText)
          .accessibilityLabel("\(title), \(value)")

        Text(subtitle)
          .appFont(.caption)
          .appMultilineText()
          .foregroundStyle(AppColors.secondaryText)
      }
    }
    .accessibilityElement(children: .combine)
  }
}
