//
//  StatisticsContentView.swift
//  FocusUp
//

import SwiftUI

struct StatisticsContentView: View {
  @Bindable var viewModel: StatisticsViewModel

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  var body: some View {
    VStack(alignment: .leading, spacing: AdaptiveSpacing.sectionSpacing(horizontalSizeClass: horizontalSizeClass)) {
      header

      StatisticsSection(title: "Overview", subtitle: "Weekly focus and task completion") {
        StatisticsCardGrid {
          WeeklySummaryCard(weekly: viewModel.summary.weeklyProgress)
          StreakAnalyticsCard(streak: viewModel.summary.streak)
        }
      }

      StatisticsSection(title: "Weekly focus", subtitle: "Minutes per day this week") {
        WeeklyChartView(
          points: viewModel.chartPoints,
          accessibilitySummary: viewModel.weeklyChartAccessibilitySummary
        )
      }

      StatisticsSection(title: "Trends", subtitle: "How this week compares to last") {
        FocusTrendChart(
          points: viewModel.chartPoints,
          trend: viewModel.summary.trend
        )
      }

      StatisticsSection(title: "Tasks & rhythm") {
        StatisticsCardGrid {
          CompletionRateChart(
            completionRate: viewModel.summary.completionRate,
            completedCount: viewModel.summary.completedTasksCount,
            trackableCount: viewModel.summary.trackableTasksCount
          )
          FocusDistributionCard(buckets: viewModel.summary.focusDistribution)
        }
      }

      StatisticsSection(title: "Insights", subtitle: "Supportive, not stressful") {
        ProductivityInsightsCard(
          trend: viewModel.summary.trend,
          averageSessionMinutes: viewModel.summary.averageSessionMinutes,
          totalSessions: viewModel.summary.totalCompletedSessions
        )
      }
    }
    .focusMotionAnimation(viewModel.summary, style: .softFade)
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
      AppTextStyles.screenTitle(viewModel.greetingTitle)
      AppTextStyles.screenSubtitle(viewModel.greetingSubtitle)

      if case .failed(let message) = viewModel.loadingState {
        Text(message)
          .appFont(.caption)
          .foregroundStyle(AppColors.error)
      }
    }
    .accessibilityElement(children: .combine)
  }
}
