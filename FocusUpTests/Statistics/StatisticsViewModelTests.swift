//
//  StatisticsViewModelTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
@Suite(.tags(.statistics))
struct StatisticsViewModelTests {
  @Test func loadPopulatesSummary() async {
    let repo = PreviewStatisticsRepository()
    repo.analytics = StatisticsPreviewData.populated
    let viewModel = StatisticsViewModel(statisticsRepository: repo)

    await viewModel.load()

    #expect(viewModel.loadingState == .loaded)
    #expect(viewModel.summary.totalCompletedSessions == 12)
    #expect(viewModel.chartPoints.count == 7)
  }

  @Test func loadFailureSetsFailedState() async {
    struct FailingRepo: StatisticsRepository {
      func fetchSummary() async throws -> FocusStatisticsSummary { throw NSError(domain: "t", code: 1) }
      func fetchAnalytics() async throws -> StatisticsSummary { throw NSError(domain: "t", code: 1) }
      func invalidateCache() {}
    }

    let viewModel = StatisticsViewModel(statisticsRepository: FailingRepo())
    await viewModel.load()

    guard case .failed = viewModel.loadingState else {
      Issue.record("Expected failed state")
      return
    }
  }

  @Test func refreshInvalidatesCache() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let repo = StatisticsRepositoryImpl(context: persistence.mainContext)
    let viewModel = StatisticsViewModel(statisticsRepository: repo)

    await viewModel.load()
    #expect(viewModel.loadingState == .loaded)

    await viewModel.refresh()
    #expect(viewModel.loadingState == .loaded)
  }
}
