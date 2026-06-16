//
//  PreviewStatisticsRepository.swift
//  FocusUp
//

import Foundation

@MainActor
final class PreviewStatisticsRepository: StatisticsRepository {
  var analytics: StatisticsSummary = StatisticsPreviewData.populated

  func fetchSummary() async throws -> FocusStatisticsSummary {
    FocusAnalyticsCalculator.focusStatisticsSummary(from: analytics)
  }

  func fetchAnalytics() async throws -> StatisticsSummary {
    analytics
  }

  func invalidateCache() {}
}
