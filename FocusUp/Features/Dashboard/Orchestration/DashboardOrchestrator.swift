//
//  DashboardOrchestrator.swift
//  FocusUp
//

import Foundation

/// Coordinates repository reads and session continuity for the dashboard — orchestration only.
@MainActor
final class DashboardOrchestrator {
  private let statisticsRepository: any StatisticsRepository
  private let taskRepository: any TaskRepository
  private let focusSessionManager: FocusSessionManager
  private let restSessionManager: RestSessionManager
  private let clock: any Clock

  init(
    statisticsRepository: any StatisticsRepository,
    taskRepository: any TaskRepository,
    focusSessionManager: FocusSessionManager,
    restSessionManager: RestSessionManager,
    clock: any Clock = SystemClock()
  ) {
    self.statisticsRepository = statisticsRepository
    self.taskRepository = taskRepository
    self.focusSessionManager = focusSessionManager
    self.restSessionManager = restSessionManager
    self.clock = clock
  }

  func refresh(invalidateStatisticsCache: Bool = false) async throws -> DashboardSnapshot {
    if invalidateStatisticsCache {
      statisticsRepository.invalidateCache()
    }

    async let analytics = statisticsRepository.fetchAnalytics()
    async let tasks = taskRepository.fetchAll()
    let statistics = try await analytics
    let allTasks = try await tasks

    return DashboardStateAggregator.buildSnapshot(
      statistics: statistics,
      tasks: allTasks,
      activeFocus: focusSessionManager.activeSession,
      activeRest: restSessionManager.activeSession?.status.isActiveLifecycle == true,
      now: clock.now()
    )
  }

  func activeSessionSnapshot(taskTitle: String?) -> DashboardActiveSessionSnapshot? {
    guard let session = focusSessionManager.activeSession,
          session.status.isActiveLifecycle else {
      return nil
    }
    return DashboardStateAggregator.activeSessionSnapshot(
      session: session,
      taskTitle: taskTitle,
      timerEngine: focusSessionManager.timerEngine,
      now: clock.now()
    )
  }

  func activeSessionSnapshot(
    at date: Date,
    taskTitle: String?
  ) -> DashboardActiveSessionSnapshot? {
    guard let session = focusSessionManager.activeSession,
          session.status.isActiveLifecycle else {
      return nil
    }
    return DashboardStateAggregator.activeSessionSnapshot(
      session: session,
      taskTitle: taskTitle,
      timerEngine: focusSessionManager.timerEngine,
      now: date
    )
  }

  func associatedTaskTitle(for session: FocusSession) async -> String? {
    guard let taskID = session.associatedTaskID else { return nil }
    return try? await taskRepository.fetch(id: taskID)?.title
  }

  func pauseActiveSession() async throws {
    try await focusSessionManager.pauseSession()
  }

  func resumeActiveSession() async throws {
    try await focusSessionManager.resumeSession()
  }

  var hasActiveFocusSession: Bool {
    focusSessionManager.activeSession?.status.isActiveLifecycle == true
  }

  var activeFocusSession: FocusSession? {
    focusSessionManager.activeSession
  }

  var hasActiveRestSession: Bool {
    restSessionManager.activeSession?.status.isActiveLifecycle == true
  }
}
