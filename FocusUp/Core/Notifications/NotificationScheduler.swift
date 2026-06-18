//
//  NotificationScheduler.swift
//  FocusUp
//

import Foundation

@MainActor
protocol NotificationScheduling: AnyObject {
  func rescheduleAll() async
  func notifySessionCompleted(title: String, sessionID: UUID) async
  func cancelTaskReminders(taskID: UUID) async
}

@MainActor
final class NotificationScheduler: NotificationScheduling {
  private let notificationService: any NotificationService
  private let preferencesRepository: any UserPreferencesRepository
  private let taskRepository: any TaskRepository
  private let clock: any Clock

  init(
    notificationService: any NotificationService,
    preferencesRepository: any UserPreferencesRepository,
    taskRepository: any TaskRepository,
    clock: any Clock = SystemClock()
  ) {
    self.notificationService = notificationService
    self.preferencesRepository = preferencesRepository
    self.taskRepository = taskRepository
    self.clock = clock
  }

  func rescheduleAll() async {
    let status = await notificationService.authorizationStatus()
    guard status.canScheduleNotifications else { return }

    let preferences = (try? await preferencesRepository.fetch()) ?? UserPreferences()
    guard preferences.notifications.hasAnyReminderEnabled else {
      await notificationService.cancelAll()
      return
    }

    await notificationService.cancelAll()
    await scheduleTaskDeadlineReminders(preferences: preferences.notifications)
    await scheduleDailyMotivation(preferences: preferences.notifications)
    await scheduleFocusReminder(preferences: preferences.notifications)
  }

  func notifySessionCompleted(title: String, sessionID: UUID) async {
    let status = await notificationService.authorizationStatus()
    guard status.canScheduleNotifications else { return }

    let preferences = (try? await preferencesRepository.fetch()) ?? UserPreferences()
    guard preferences.notifications.sessionCompletionRemindersEnabled else { return }

    let now = clock.now()
    let fireDate = QuietHoursManager.adjustedDeliveryDate(
      for: now,
      quietHours: preferences.notifications.quietHours
    )
    let message = MotivationMessageGenerator.message(
      for: .sessionComplete(title: title),
      seed: now
    )

    let request = LocalNotificationRequest(
      identifier: NotificationIdentifier.sessionComplete(sessionID),
      title: message.title,
      body: message.body,
      category: .sessionComplete,
      fireDate: fireDate
    )

    try? await notificationService.schedule(request)
  }

  func cancelTaskReminders(taskID: UUID) async {
    await notificationService.cancel(identifiers: [NotificationIdentifier.taskDeadline(taskID)])
  }

  // MARK: - Private

  private func scheduleTaskDeadlineReminders(preferences: NotificationPreferences) async {
    guard preferences.taskDeadlineRemindersEnabled else { return }

    guard let tasks = try? await taskRepository.fetchAll() else { return }
    let now = clock.now()

    for task in tasks {
      guard TaskDeadlineReminderPlanner.shouldSchedule(
        isCompleted: task.isCompleted,
        deadline: task.deadline,
        now: now
      ), let deadline = task.deadline else { continue }

      guard let proposedFireDate = TaskDeadlineReminderPlanner.fireDate(for: deadline, now: now) else {
        continue
      }

      let adjustedFireDate = QuietHoursManager.adjustedDeliveryDate(
        for: proposedFireDate,
        quietHours: preferences.quietHours
      )

      let window = TaskDeadlineReminderPlanner.deadlineWindow(for: deadline)
      let fireDate: Date
      if adjustedFireDate <= window.endOfDeadlineDay {
        fireDate = adjustedFireDate
      } else if let fallback = fallbackFireDateBeforeQuietHours(
        on: window.deadlineDay,
        now: now,
        quietHours: preferences.quietHours
      ) {
        fireDate = fallback
      } else {
        continue
      }

      let message = MotivationMessageGenerator.message(
        for: .taskDeadline(title: task.title),
        seed: deadline
      )

      let request = LocalNotificationRequest(
        identifier: NotificationIdentifier.taskDeadline(task.id),
        title: message.title,
        body: message.body,
        category: .taskDeadline,
        fireDate: fireDate
      )
      try? await notificationService.schedule(request)
    }
  }

  private func fallbackFireDateBeforeQuietHours(
    on deadlineDay: Date,
    now: Date,
    quietHours: QuietHoursConfiguration,
    calendar: Calendar = .current
  ) -> Date? {
    guard quietHours.isEnabled, quietHours.spansMidnight else { return nil }

    var startComponents = calendar.dateComponents([.year, .month, .day], from: deadlineDay)
    startComponents.hour = quietHours.startHour
    startComponents.minute = quietHours.startMinute
    startComponents.second = 0
    guard let quietStart = calendar.date(from: startComponents) else { return nil }

    let fallback = quietStart.addingTimeInterval(-60)
    let earliest = now.addingTimeInterval(60)
    let window = TaskDeadlineReminderPlanner.deadlineWindow(for: deadlineDay, calendar: calendar)
    guard fallback >= earliest, fallback <= window.endOfDeadlineDay else { return nil }
    guard !quietHours.contains(date: fallback, calendar: calendar) else { return nil }
    return fallback
  }

  private func scheduleFocusReminder(preferences: NotificationPreferences) async {
    guard preferences.focusRemindersEnabled else { return }

    let now = clock.now()
    var components = Calendar.current.dateComponents([.year, .month, .day], from: now)
    components.hour = 10
    components.minute = 30
    guard var fireDate = Calendar.current.date(from: components) else { return }
    if fireDate <= now {
      fireDate = Calendar.current.date(byAdding: .day, value: 1, to: fireDate) ?? fireDate
    }

    fireDate = QuietHoursManager.adjustedDeliveryDate(
      for: fireDate,
      quietHours: preferences.quietHours
    )

    let message = MotivationMessageGenerator.message(for: .focusReminder, seed: fireDate)
    let request = LocalNotificationRequest(
      identifier: NotificationIdentifier.focusReminder,
      title: message.title,
      body: message.body,
      category: .focusReminder,
      fireDate: fireDate,
      repeatsDaily: true
    )
    try? await notificationService.schedule(request)
  }

  private func scheduleDailyMotivation(preferences: NotificationPreferences) async {
    guard preferences.motivationalRemindersEnabled else { return }

    let now = clock.now()
    var components = Calendar.current.dateComponents([.year, .month, .day], from: now)
    components.hour = 9
    components.minute = 0
    guard var fireDate = Calendar.current.date(from: components) else { return }
    if fireDate <= now {
      fireDate = Calendar.current.date(byAdding: .day, value: 1, to: fireDate) ?? fireDate
    }

    fireDate = QuietHoursManager.adjustedDeliveryDate(
      for: fireDate,
      quietHours: preferences.quietHours
    )

    let message = MotivationMessageGenerator.message(for: .dailyEncouragement, seed: fireDate)
    let request = LocalNotificationRequest(
      identifier: NotificationIdentifier.dailyMotivation,
      title: message.title,
      body: message.body,
      category: .motivation,
      fireDate: fireDate,
      repeatsDaily: true
    )
    try? await notificationService.schedule(request)
  }
}
