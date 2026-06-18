//
//  WeeklySummaryCard.swift
//  FocusUp
//

import SwiftUI

struct WeeklySummaryCard: View {
  let weekly: WeeklyProgress


  var body: some View {
    AppCard {
      VStack(alignment: .leading, spacing: AppSpacing.sm) {
        Label("Weekly summary", systemImage: "calendar")
          .appFont(.headline)
          .foregroundStyle(AppColors.focus)

        Text(StatisticsFormatting.minutesLabel(weekly.totalMinutes))
          .font(AppTypography.metric())
          .foregroundStyle(AppColors.primaryText)

        Text("\(weekly.completedSessions) sessions · goal \(StatisticsFormatting.minutesLabel(weekly.goalMinutes))")
          .appFont(.caption)
          .foregroundStyle(AppColors.secondaryText)

        GeometryReader { proxy in
          ZStack(alignment: .leading) {
            Capsule()
              .fill(AppColors.focus.opacity(0.2))
            Capsule()
              .fill(AppColors.focus)
              .frame(width: max(4, proxy.size.width * weekly.progress))
          }
        }
        .frame(height: 6)
        .focusMotionAnimation(weekly.progress, style: .progress)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(
      "Weekly summary. \(StatisticsFormatting.minutesLabel(weekly.totalMinutes)). \(weekly.completedSessions) sessions."
    )
  }
}
