//
//  LocalNotificationRequest.swift
//  FocusUp
//

import Foundation

enum NotificationCategory: String, Codable, Sendable {
  case focusReminder
  case taskDeadline
  case sessionComplete
  case motivation
}

struct LocalNotificationRequest: Equatable, Sendable {
  var identifier: String
  var title: String
  var body: String
  var category: NotificationCategory
  var fireDate: Date
  var repeatsDaily: Bool

  init(
    identifier: String,
    title: String,
    body: String,
    category: NotificationCategory,
    fireDate: Date,
    repeatsDaily: Bool = false
  ) {
    self.identifier = identifier
    self.title = title
    self.body = body
    self.category = category
    self.fireDate = fireDate
    self.repeatsDaily = repeatsDaily
  }
}

enum NotificationIdentifier {
  static func taskDeadline(_ taskID: UUID) -> String {
    "task-deadline-\(taskID.uuidString)"
  }

  static let dailyMotivation = "motivation-daily"
  static let focusReminder = "focus-reminder-daily"

  static func sessionComplete(_ sessionID: UUID) -> String {
    "session-complete-\(sessionID.uuidString)"
  }
}
