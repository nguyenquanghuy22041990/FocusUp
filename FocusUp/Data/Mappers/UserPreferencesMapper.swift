//
//  UserPreferencesMapper.swift
//  FocusUp
//

import Foundation
import SwiftData

enum UserPreferencesMapper {
  static func toDomain(_ entity: UserPreferencesEntity) -> UserPreferences {
    UserPreferences(
      id: entity.id,
      prefersReducedMotion: entity.prefersReducedMotion,
      voiceOverHintsEnabled: entity.voiceOverHintsEnabled,
      hapticsEnabled: entity.hapticsEnabled,
      notifications: NotificationPreferences(
        hasSeenPermissionEducation: entity.hasSeenNotificationPermissionEducation,
        focusRemindersEnabled: entity.focusRemindersEnabled,
        taskDeadlineRemindersEnabled: entity.taskDeadlineRemindersEnabled,
        sessionCompletionRemindersEnabled: entity.sessionCompletionRemindersEnabled,
        motivationalRemindersEnabled: entity.motivationalRemindersEnabled,
        quietHours: QuietHoursConfiguration(
          isEnabled: entity.quietHoursEnabled,
          startHour: entity.quietHoursStartHour,
          startMinute: entity.quietHoursStartMinute,
          endHour: entity.quietHoursEndHour,
          endMinute: entity.quietHoursEndMinute
        )
      ),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt
    )
  }

  static func toEntity(_ domain: UserPreferences, context: ModelContext) -> UserPreferencesEntity {
    if let existing = fetchEntity(id: domain.id, context: context) {
      updateEntity(existing, from: domain)
      return existing
    }

    let notifications = domain.notifications
    let entity = UserPreferencesEntity(
      id: domain.id,
      prefersReducedMotion: domain.prefersReducedMotion,
      voiceOverHintsEnabled: domain.voiceOverHintsEnabled,
      hapticsEnabled: domain.hapticsEnabled,
      hasSeenNotificationPermissionEducation: notifications.hasSeenPermissionEducation,
      focusRemindersEnabled: notifications.focusRemindersEnabled,
      taskDeadlineRemindersEnabled: notifications.taskDeadlineRemindersEnabled,
      sessionCompletionRemindersEnabled: notifications.sessionCompletionRemindersEnabled,
      motivationalRemindersEnabled: notifications.motivationalRemindersEnabled,
      quietHoursEnabled: notifications.quietHours.isEnabled,
      quietHoursStartHour: notifications.quietHours.startHour,
      quietHoursStartMinute: notifications.quietHours.startMinute,
      quietHoursEndHour: notifications.quietHours.endHour,
      quietHoursEndMinute: notifications.quietHours.endMinute,
      createdAt: domain.createdAt,
      updatedAt: domain.updatedAt
    )
    context.insert(entity)
    return entity
  }

  static func updateEntity(_ entity: UserPreferencesEntity, from domain: UserPreferences) {
    entity.prefersReducedMotion = domain.prefersReducedMotion
    entity.voiceOverHintsEnabled = domain.voiceOverHintsEnabled
    entity.hapticsEnabled = domain.hapticsEnabled
    entity.hasSeenNotificationPermissionEducation = domain.notifications.hasSeenPermissionEducation
    entity.focusRemindersEnabled = domain.notifications.focusRemindersEnabled
    entity.taskDeadlineRemindersEnabled = domain.notifications.taskDeadlineRemindersEnabled
    entity.sessionCompletionRemindersEnabled = domain.notifications.sessionCompletionRemindersEnabled
    entity.motivationalRemindersEnabled = domain.notifications.motivationalRemindersEnabled
    entity.quietHoursEnabled = domain.notifications.quietHours.isEnabled
    entity.quietHoursStartHour = domain.notifications.quietHours.startHour
    entity.quietHoursStartMinute = domain.notifications.quietHours.startMinute
    entity.quietHoursEndHour = domain.notifications.quietHours.endHour
    entity.quietHoursEndMinute = domain.notifications.quietHours.endMinute
    entity.updatedAt = .now
  }

  private static func fetchEntity(id: UUID, context: ModelContext) -> UserPreferencesEntity? {
    let descriptor = FetchDescriptor<UserPreferencesEntity>(
      predicate: #Predicate { $0.id == id }
    )
    return try? context.fetch(descriptor).first
  }
}
