//
//  StatisticsRepositoryImpl.swift
//  FocusUp
//

import Foundation
import SwiftData

@MainActor
final class StatisticsRepositoryImpl: StatisticsRepository {
  private let context: ModelContext
  private var cachedAnalytics: StatisticsSummary?
  private var cacheTimestamp: Date?
  private let cacheLifetime: TimeInterval = 30

  init(context: ModelContext) {
    self.context = context
  }

  func invalidateCache() {
    cachedAnalytics = nil
    cacheTimestamp = nil
  }

  func fetchSummary() async throws -> FocusStatisticsSummary {
    let analytics = try await fetchAnalytics()
    return FocusAnalyticsCalculator.focusStatisticsSummary(from: analytics)
  }

  func fetchAnalytics() async throws -> StatisticsSummary {
    if let cachedAnalytics,
       let cacheTimestamp,
       Date().timeIntervalSince(cacheTimestamp) < cacheLifetime {
      return cachedAnalytics
    }

    let sessions = try fetchCompletedSessions()
    let tasks = try fetchTasks()
    let summary = FocusAnalyticsCalculator.buildStatisticsSummary(
      completedSessions: sessions,
      tasks: tasks
    )
    cachedAnalytics = summary
    cacheTimestamp = .now
    return summary
  }

  // MARK: - Private

  private func fetchCompletedSessions() throws -> [FocusSession] {
    let completed = FocusSessionStatus.completed.rawValue
    let descriptor = FetchDescriptor<FocusSessionEntity>(
      predicate: #Predicate { $0.statusRawValue == completed },
      sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
    )
    return try context.fetch(descriptor).map(FocusSessionMapper.toDomain)
  }

  private func fetchTasks() throws -> [Task] {
    let descriptor = FetchDescriptor<TaskEntity>(
      sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
    )
    return try context.fetch(descriptor).map(TaskMapper.toDomain)
  }
}
