//
//  DomainFixtures.swift
//  FocusUp
//

import Foundation

enum DomainFixtures {
  static func task(
    title: String = "Fixture Task",
    status: TaskStatus = .todo,
    priority: TaskPriority = .medium
  ) -> Task {
    Task(title: title, priority: priority, status: status)
  }

  static func focusSession(
    title: String = "Fixture Session",
    status: FocusSessionStatus = .planned,
    plannedDurationSeconds: Int = 25 * 60,
    elapsedSeconds: Int = 0,
    segmentStartedAt: Date? = nil,
    sessionStartedAt: Date? = nil
  ) -> FocusSession {
    FocusSession(
      title: title,
      plannedDurationSeconds: plannedDurationSeconds,
      elapsedSeconds: elapsedSeconds,
      status: status,
      segmentStartedAt: segmentStartedAt,
      sessionStartedAt: sessionStartedAt
    )
  }

  static var preferences: UserPreferences {
    UserPreferences()
  }
}
