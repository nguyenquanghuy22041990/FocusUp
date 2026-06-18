//
//  NotificationSchedulerIntegrationTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct NotificationSchedulerIntegrationTests {
  @Test(.tags(.notifications, .production))
  func rescheduleAllClearsBeforeScheduling() async throws {
    let notify = NoOpNotificationService()
    notify.authorization = .authorized
    notify.scheduled = [
      LocalNotificationRequest(
        identifier: "stale",
        title: "Old",
        body: "Old",
        category: .motivation,
        fireDate: .now
      )
    ]

    let persistence = try PersistenceController(inMemory: true)
    let scheduler = NotificationScheduler(
      notificationService: notify,
      preferencesRepository: UserPreferencesRepositoryImpl(context: persistence.mainContext),
      taskRepository: TaskRepositoryImpl(context: persistence.mainContext)
    )

    await scheduler.rescheduleAll()

    #expect(notify.cancelAllCount >= 1)
    #expect(!notify.scheduled.contains { $0.identifier == "stale" })
    #expect(notify.scheduled.allSatisfy { $0.identifier != "stale" })
  }

  @Test(.tags(.notifications, .production))
  func cancelTaskRemindersRemovesDeadlineNotification() async {
    let notify = NoOpNotificationService()
    notify.authorization = .authorized
    let taskID = UUID()
    notify.scheduled = [
      LocalNotificationRequest(
        identifier: NotificationIdentifier.taskDeadline(taskID),
        title: "Due",
        body: "Soon",
        category: .taskDeadline,
        fireDate: .now.addingTimeInterval(3600)
      )
    ]

    let scheduler = NotificationScheduler(
      notificationService: notify,
      preferencesRepository: PreviewUserPreferencesRepository(),
      taskRepository: PreviewTaskRepository()
    )

    await scheduler.cancelTaskReminders(taskID: taskID)

    #expect(notify.lastCancelledIdentifiers.contains(NotificationIdentifier.taskDeadline(taskID)))
    #expect(!notify.scheduled.contains { $0.identifier == NotificationIdentifier.taskDeadline(taskID) })
  }

  @Test(.tags(.notifications, .production))
  func sessionCompleteUsesStableIdentifier() async throws {
    let notify = NoOpNotificationService()
    notify.authorization = .authorized
    let sessionID = UUID()

    let scheduler = NotificationScheduler(
      notificationService: notify,
      preferencesRepository: UserPreferencesRepositoryImpl(
        context: try PersistenceController(inMemory: true).mainContext
      ),
      taskRepository: PreviewTaskRepository()
    )

    await scheduler.notifySessionCompleted(title: "Focus", sessionID: sessionID)
    await scheduler.notifySessionCompleted(title: "Focus", sessionID: sessionID)

    let matching = notify.scheduled.filter {
      $0.identifier == NotificationIdentifier.sessionComplete(sessionID)
    }
    #expect(matching.count == 2)
    #expect(matching[0].identifier == matching[1].identifier)
  }
}
