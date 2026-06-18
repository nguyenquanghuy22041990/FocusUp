//
//  UserPreferencesEntity.swift
//  FocusUp
//

import Foundation
import SwiftData

@Model
final class UserPreferencesEntity {
  @Attribute(.unique) var id: UUID
  var prefersReducedMotion: Bool
  var voiceOverHintsEnabled: Bool
  var hapticsEnabled: Bool
  var hasSeenNotificationPermissionEducation: Bool
  var focusRemindersEnabled: Bool
  var taskDeadlineRemindersEnabled: Bool
  var sessionCompletionRemindersEnabled: Bool
  var motivationalRemindersEnabled: Bool
  var quietHoursEnabled: Bool
  var quietHoursStartHour: Int
  var quietHoursStartMinute: Int
  var quietHoursEndHour: Int
  var quietHoursEndMinute: Int
  var createdAt: Date
  var updatedAt: Date

  init(
    id: UUID = UserPreferences.singletonID,
    prefersReducedMotion: Bool = false,
    voiceOverHintsEnabled: Bool = true,
    hapticsEnabled: Bool = true,
    hasSeenNotificationPermissionEducation: Bool = false,
    focusRemindersEnabled: Bool = true,
    taskDeadlineRemindersEnabled: Bool = true,
    sessionCompletionRemindersEnabled: Bool = true,
    motivationalRemindersEnabled: Bool = true,
    quietHoursEnabled: Bool = true,
    quietHoursStartHour: Int = 22,
    quietHoursStartMinute: Int = 0,
    quietHoursEndHour: Int = 7,
    quietHoursEndMinute: Int = 0,
    createdAt: Date = .now,
    updatedAt: Date = .now
  ) {
    self.id = id
    self.prefersReducedMotion = prefersReducedMotion
    self.voiceOverHintsEnabled = voiceOverHintsEnabled
    self.hapticsEnabled = hapticsEnabled
    self.hasSeenNotificationPermissionEducation = hasSeenNotificationPermissionEducation
    self.focusRemindersEnabled = focusRemindersEnabled
    self.taskDeadlineRemindersEnabled = taskDeadlineRemindersEnabled
    self.sessionCompletionRemindersEnabled = sessionCompletionRemindersEnabled
    self.motivationalRemindersEnabled = motivationalRemindersEnabled
    self.quietHoursEnabled = quietHoursEnabled
    self.quietHoursStartHour = quietHoursStartHour
    self.quietHoursStartMinute = quietHoursStartMinute
    self.quietHoursEndHour = quietHoursEndHour
    self.quietHoursEndMinute = quietHoursEndMinute
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
