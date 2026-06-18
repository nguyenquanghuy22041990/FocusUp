//
//  ProductivityInsightsCard.swift
//  FocusUp
//

import SwiftUI

struct ProductivityInsightsCard: View {
  let trend: ProductivityTrend
  let averageSessionMinutes: Int
  let totalSessions: Int

  private var trendIcon: String {
    switch trend.direction {
    case .up: "arrow.up.right"
    case .down: "arrow.down.right"
    case .stable: "arrow.right"
    }
  }

  private var trendTint: Color {
    switch trend.direction {
    case .up: AppColors.success
    case .down: AppColors.secondaryText
    case .stable: AppColors.focus
    }
  }

  var body: some View {
    AppCard {
      VStack(alignment: .leading, spacing: AppSpacing.sm) {
        Label("Insights", systemImage: "lightbulb.fill")
          .appFont(.headline)
          .foregroundStyle(AppColors.focus)

        HStack(alignment: .top, spacing: AppSpacing.sm) {
          Image(systemName: trendIcon)
            .foregroundStyle(trendTint)
            .accessibilityHidden(true)

          Text(trend.insight)
            .appFont(.body)
            .appMultilineText()
            .foregroundStyle(AppColors.secondaryText)
        }

        Text(
          "Average session \(StatisticsFormatting.minutesLabel(max(1, averageSessionMinutes))). \(totalSessions) sessions completed overall."
        )
        .appFont(.caption)
        .foregroundStyle(AppColors.tertiaryText)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Insights. \(trend.insight)")
  }
}
