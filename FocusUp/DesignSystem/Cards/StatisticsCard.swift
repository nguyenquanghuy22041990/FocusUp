//
//  StatisticsCard.swift
//  FocusUp
//

import SwiftUI

struct StatisticsCard<Chart: View>: View {
  let title: String
  let summary: String
  @ViewBuilder var chart: () -> Chart

  var body: some View {
    AppCard {
      VStack(alignment: .leading, spacing: AppSpacing.md) {
        Text(title)
          .appFont(.headline)
          .accessibilityAddTraits(.isHeader)

        chart()
          .frame(maxWidth: .infinity, minHeight: 120)
          .background(AppColors.surfaceElevated)
          .clipShape(RoundedRectangle(cornerRadius: AppSpacing.sm, style: .continuous))
          .accessibilityHidden(true)

        Text(summary)
          .appFont(.body)
          .appMultilineText()
          .foregroundStyle(AppColors.secondaryText)
      }
    }
  }
}
