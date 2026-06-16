//
//  StatisticsRepository.swift
//  FocusUp
//

import Foundation

@MainActor
protocol StatisticsRepository {
  func fetchSummary() async throws -> FocusStatisticsSummary
  func fetchAnalytics() async throws -> StatisticsSummary
  func invalidateCache()
}
