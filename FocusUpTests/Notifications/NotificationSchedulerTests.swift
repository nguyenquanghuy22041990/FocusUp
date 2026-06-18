//
//  NotificationSchedulerTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
@Suite(.tags(.notifications))
struct NotificationSchedulerTests {
  @Test func rescheduleAllSchedulesTaskDeadline() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let taskRepo = TaskRepositoryImpl(context: persistence.mainContext)
    let prefsRepo = UserPreferencesRepositoryImpl(context: persistence.mainContext)

    var task = DomainFixtures.task(title: "Due soon", status: .todo)
    task.deadline = Date().addingTimeInterval(86_400)
    try await taskRepo.create(task)

    let notify = NoOpNotificationService()
    notify.authorization = .authorized

    let scheduler = NotificationScheduler(
      notificationService: notify,
      preferencesRepository: prefsRepo,
      taskRepository: taskRepo
    )

    await scheduler.rescheduleAll()

    #expect(notify.scheduled.contains { $0.category == .taskDeadline })
  }

  @Test func rescheduleAllSchedulesDeadlineDueToday() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let taskRepo = TaskRepositoryImpl(context: persistence.mainContext)
    let prefsRepo = UserPreferencesRepositoryImpl(context: persistence.mainContext)

    let calendar = Calendar.current
    let now = calendar.date(from: DateComponents(year: 2026, month: 6, day: 2, hour: 21, minute: 41))!
    var task = DomainFixtures.task(title: "Due today", status: .todo)
    task.deadline = calendar.startOfDay(for: now)
    try await taskRepo.create(task)

    let notify = NoOpNotificationService()
    notify.authorization = .authorized
    let clock = TestClock(startingAt: now)

    let scheduler = NotificationScheduler(
      notificationService: notify,
      preferencesRepository: prefsRepo,
      taskRepository: taskRepo,
      clock: clock
    )

    await scheduler.rescheduleAll()

    let deadlineRequest = notify.scheduled.first { $0.category == .taskDeadline }
    #expect(deadlineRequest != nil)
    #expect(deadlineRequest!.fireDate > now)
    #expect(deadlineRequest!.title.contains("Due today"))
    #expect(deadlineRequest!.body.contains("deadline is approaching"))
  }

  @Test func sessionCompleteSchedulesWhenEnabled() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let prefsRepo = UserPreferencesRepositoryImpl(context: persistence.mainContext)
    let notify = NoOpNotificationService()
    notify.authorization = .authorized

    let scheduler = NotificationScheduler(
      notificationService: notify,
      preferencesRepository: prefsRepo,
      taskRepository: TaskRepositoryImpl(context: persistence.mainContext)
    )

    await scheduler.notifySessionCompleted(title: "Deep work", sessionID: UUID())

    #expect(notify.scheduled.contains { $0.category == .sessionComplete })
  }

  @Test func rescheduleSkipsWhenUnauthorized() async {
    let notify = NoOpNotificationService()
    notify.authorization = .denied

    let scheduler = NotificationScheduler(
      notificationService: notify,
      preferencesRepository: PreviewUserPreferencesRepository(),
      taskRepository: PreviewTaskRepository()
    )

    await scheduler.rescheduleAll()
    #expect(notify.scheduled.isEmpty)
  }
}
