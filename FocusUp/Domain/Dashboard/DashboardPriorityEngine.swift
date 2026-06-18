//
//  DashboardPriorityEngine.swift
//  FocusUp
//

import Foundation

/// Deterministic task prioritization for dashboard surfacing — no AI, repository-driven inputs only.
enum DashboardPriorityEngine {
  private static let maxRecommendations = 5
  private static let nearDeadlineHours = 72

  static func recommendations(
    from tasks: [Task],
    now: Date = .now,
    calendar: Calendar = .current
  ) -> [DashboardPriorityRecommendation] {
    let candidates = tasks
      .filter { $0.status != .archived && !$0.isCompleted }
      .compactMap { scoredRecommendation(for: $0, now: now, calendar: calendar) }
      .sorted { $0.urgencyScore > $1.urgencyScore }

    return Array(candidates.prefix(maxRecommendations))
  }

  private static func scoredRecommendation(
    for task: Task,
    now: Date,
    calendar: Calendar
  ) -> DashboardPriorityRecommendation? {
    var score = 0
    var reasons: [String] = []

    if task.status == .inProgress {
      score += 40
      reasons.append("in progress")
    }

    switch task.priority {
    case .high: score += 30
    case .medium: score += 15
    case .low: score += 5
    }

    let openMilestones = task.milestones.filter { !$0.isCompleted }
    if !openMilestones.isEmpty {
      score += 20
      reasons.append("open milestones")
    }

    if let deadline = task.deadline {
      if deadline < now {
        score += 100
        reasons.append("overdue")
      } else if let hours = calendar.dateComponents([.hour], from: now, to: deadline).hour, hours <= 24 {
        score += 80
        reasons.append("due soon")
      } else if let hours = calendar.dateComponents([.hour], from: now, to: deadline).hour,
                hours <= nearDeadlineHours {
        score += 50
        reasons.append("approaching deadline")
      }
    }

    guard score > 0 else { return nil }

    let reason = reasons.isEmpty
      ? "Worth a calm next step"
      : reasons.map { $0.capitalized }.joined(separator: " · ")

    return DashboardPriorityRecommendation(
      id: task.id,
      taskID: task.id,
      title: task.title,
      reason: reason,
      urgencyScore: score,
      hasIncompleteMilestones: !openMilestones.isEmpty
    )
  }
}
