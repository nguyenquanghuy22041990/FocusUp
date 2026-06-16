//
//  NotificationPreferences.swift
//  FocusUp
//

import Foundation

struct NotificationPreferences: Equatable, Codable, Sendable {
  var hasSeenPermissionEducation: Bool
  var focusRemindersEnabled: Bool
  var taskDeadlineRemindersEnabled: Bool
  var sessionCompletionRemindersEnabled: Bool
  var motivationalRemindersEnabled: Bool
  var quietHours: QuietHoursConfiguration

  init(
    hasSeenPermissionEducation: Bool = false,
    focusRemindersEnabled: Bool = true,
    taskDeadlineRemindersEnabled: Bool = true,
    sessionCompletionRemindersEnabled: Bool = true,
    motivationalRemindersEnabled: Bool = true,
    quietHours: QuietHoursConfiguration = .default
  ) {
    self.hasSeenPermissionEducation = hasSeenPermissionEducation
    self.focusRemindersEnabled = focusRemindersEnabled
    self.taskDeadlineRemindersEnabled = taskDeadlineRemindersEnabled
    self.sessionCompletionRemindersEnabled = sessionCompletionRemindersEnabled
    self.motivationalRemindersEnabled = motivationalRemindersEnabled
    self.quietHours = quietHours
  }

  static let `default` = NotificationPreferences()

  var hasAnyReminderEnabled: Bool {
    focusRemindersEnabled
      || taskDeadlineRemindersEnabled
      || sessionCompletionRemindersEnabled
      || motivationalRemindersEnabled
  }
}
