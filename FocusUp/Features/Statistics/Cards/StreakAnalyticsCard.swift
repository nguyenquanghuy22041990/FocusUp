//
//  StreakAnalyticsCard.swift
//  FocusUp
//

import SwiftUI

struct StreakAnalyticsCard: View {
  let streak: StreakStatistics

  var body: some View {
    AppCard {
      VStack(alignment: .leading, spacing: AppSpacing.sm) {
        Label("Streak", systemImage: "flame.fill")
          .appFont(.headline)
          .foregroundStyle(AppColors.warning)

        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.lg) {
          VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("\(streak.currentStreakDays)")
              .font(AppTypography.metric())
            Text("Current days")
              .appFont(.caption)
              .foregroundStyle(AppColors.secondaryText)
          }

          VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("\(streak.longestStreakDays)")
              .font(AppTypography.metric())
            Text("Longest")
              .appFont(.caption)
              .foregroundStyle(AppColors.secondaryText)
          }
        }
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(
      "Streak. \(streak.currentStreakDays) current days. Longest streak \(streak.longestStreakDays) days."
    )
  }
}
