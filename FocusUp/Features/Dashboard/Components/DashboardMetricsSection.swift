//
//  DashboardMetricsSection.swift
//  FocusUp
//

import SwiftUI

struct DashboardMetricsSection: View {
  let statistics: StatisticsSummary

  var body: some View {
    StatisticsSection(title: "At a glance", subtitle: "This week's calm progress") {
      StatisticsCardGrid {
        WeeklySummaryCard(weekly: statistics.weeklyProgress)
        StreakAnalyticsCard(streak: statistics.streak)
      }
    }
  }
}
