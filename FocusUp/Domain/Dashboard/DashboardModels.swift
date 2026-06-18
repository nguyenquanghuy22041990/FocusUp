//
//  DashboardModels.swift
//  FocusUp
//

import Foundation

enum DashboardMood: String, Equatable, Sendable, CaseIterable {
  case empty
  case morning
  case activeFocus
  case highProductivity
  case recovery
  case completedDay
}

enum DashboardLoadingState: Equatable, Sendable {
  case idle
  case loading
  case loaded
  case failed(String)
}

struct DashboardActiveSessionSnapshot: Equatable, Sendable {
  let sessionID: UUID
  let title: String
  let taskTitle: String?
  let progress: Double
  let remainingSeconds: Int
  let remainingLabel: String
  let isPaused: Bool
  let accessibilitySummary: String
}

struct DashboardPriorityRecommendation: Equatable, Sendable, Identifiable {
  let id: UUID
  let taskID: UUID
  let title: String
  let reason: String
  let urgencyScore: Int
  let hasIncompleteMilestones: Bool
}

struct DashboardContinuityState: Equatable, Sendable {
  var hasActiveFocus: Bool
  var hasActiveRest: Bool
  var canResumeFocus: Bool
  var restorationHint: String?

  static let none = DashboardContinuityState(
    hasActiveFocus: false,
    hasActiveRest: false,
    canResumeFocus: false,
    restorationHint: nil
  )
}

struct DashboardSnapshot: Equatable, Sendable {
  var mood: DashboardMood
  var greetingTitle: String
  var greetingSubtitle: String
  var statistics: StatisticsSummary
  var priorities: [DashboardPriorityRecommendation]
  var continuity: DashboardContinuityState
  var motivationalTitle: String
  var motivationalBody: String
  var todayFocusMinutes: Int
  var hasOpenTasks: Bool

  static let empty = DashboardSnapshot(
    mood: .empty,
    greetingTitle: "Welcome",
    greetingSubtitle: "Your calm productivity home.",
    statistics: .empty,
    priorities: [],
    continuity: .none,
    motivationalTitle: "Start gently",
    motivationalBody: "A short focus block is enough to begin. No pressure.",
    todayFocusMinutes: 0,
    hasOpenTasks: false
  )
}
