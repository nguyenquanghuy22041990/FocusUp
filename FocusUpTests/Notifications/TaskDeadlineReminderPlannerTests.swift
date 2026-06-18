//
//  TaskDeadlineReminderPlannerTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

struct TaskDeadlineReminderPlannerTests {
  @Test(.tags(.notifications))
  func shouldScheduleForDeadlineToday() {
    let calendar = Calendar.current
    let now = calendar.date(from: DateComponents(year: 2026, month: 5, day: 28, hour: 16))!
    let deadline = calendar.startOfDay(for: now)

    #expect(
      TaskDeadlineReminderPlanner.shouldSchedule(
        isCompleted: false,
        deadline: deadline,
        now: now,
        calendar: calendar
      )
    )
  }

  @Test(.tags(.notifications))
  func shouldNotScheduleForPastDeadlineDay() {
    let calendar = Calendar.current
    let now = calendar.date(from: DateComponents(year: 2026, month: 5, day: 28, hour: 16))!
    let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))!

    #expect(
      !TaskDeadlineReminderPlanner.shouldSchedule(
        isCompleted: false,
        deadline: yesterday,
        now: now,
        calendar: calendar
      )
    )
  }

  @Test(.tags(.notifications))
  func fireDateForSameDayDeadlineIsLaterToday() {
    let calendar = Calendar.current
    let now = calendar.date(from: DateComponents(year: 2026, month: 5, day: 28, hour: 16))!
    let deadline = calendar.startOfDay(for: now)

    let fire = TaskDeadlineReminderPlanner.fireDate(for: deadline, now: now, calendar: calendar)

    #expect(fire != nil)
    #expect(fire! > now)
    let window = TaskDeadlineReminderPlanner.deadlineWindow(for: deadline, calendar: calendar)
    #expect(fire! <= window.endOfDeadlineDay)
  }

  @Test(.tags(.notifications))
  func fireDateWhenNearEndOfDayUsesMinimumLeadTime() {
    let calendar = Calendar.current
    let now = calendar.date(from: DateComponents(year: 2026, month: 5, day: 28, hour: 23, minute: 30))!
    let deadline = calendar.startOfDay(for: now)

    let fire = TaskDeadlineReminderPlanner.fireDate(for: deadline, now: now, calendar: calendar)

    #expect(fire != nil)
    #expect(fire! >= now.addingTimeInterval(60))
  }
}
