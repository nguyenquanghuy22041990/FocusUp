//
//  StatisticsViewModel.swift
//  FocusUp
//

import Foundation
import Observation

enum StatisticsLoadingState: Equatable, Sendable {
  case idle
  case loading
  case loaded
  case failed(String)
}

@MainActor
@Observable
final class StatisticsViewModel {
  private let statisticsRepository: any StatisticsRepository

  private(set) var loadingState: StatisticsLoadingState = .idle
  private(set) var summary: StatisticsSummary = .empty

  var chartPoints: [ChartDayPoint] {
    ChartDayPoint.from(daily: summary.weeklyProgress.dailyFocus)
  }

  var greetingTitle: String { "Statistics" }

  var greetingSubtitle: String {
    switch loadingState {
    case .loading:
      return "Gathering your calm analytics…"
    case .failed:
      return "Pull to refresh when you're ready."
    case .loaded, .idle:
      if summary.totalCompletedSessions == 0 {
        return "Your trends will appear as you complete focus sessions."
      }
      return "Meaningful patterns from your focus and tasks."
    }
  }

  var weeklyChartAccessibilitySummary: String {
    StatisticsFormatting.chartAccessibilitySummary(weekly: summary.weeklyProgress)
  }

  init(statisticsRepository: any StatisticsRepository) {
    self.statisticsRepository = statisticsRepository
  }

  func load() async {
    loadingState = .loading
    do {
      summary = try await statisticsRepository.fetchAnalytics()
      loadingState = .loaded
    } catch {
      loadingState = .failed(error.localizedDescription)
    }
  }

  func refresh() async {
    statisticsRepository.invalidateCache()
    await load()
  }

  #if DEBUG
  func configureForPreview(
    summary: StatisticsSummary,
    loadingState: StatisticsLoadingState = .loaded
  ) {
    self.summary = summary
    self.loadingState = loadingState
  }
  #endif
}
