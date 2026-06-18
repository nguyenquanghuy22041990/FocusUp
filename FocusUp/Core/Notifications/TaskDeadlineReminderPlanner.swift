//
//  TaskDeadlineReminderPlanner.swift
//  FocusUp
//

import Foundation

/// Pure scheduling rules for task deadline local notifications.
enum TaskDeadlineReminderPlanner {
  struct DeadlineWindow: Equatable, Sendable {
    let deadlineDay: Date
    let endOfDeadlineDay: Date
  }

  static func deadlineWindow(for deadline: Date, calendar: Calendar = .current) -> DeadlineWindow {
    let deadlineDay = calendar.startOfDay(for: deadline)
    let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: deadlineDay) ?? deadlineDay
    let endOfDeadlineDay = startOfNextDay.addingTimeInterval(-1)
    return DeadlineWindow(deadlineDay: deadlineDay, endOfDeadlineDay: endOfDeadlineDay)
  }

  /// Whether an incomplete task with this deadline should receive a reminder.
  static func shouldSchedule(
    isCompleted: Bool,
    deadline: Date?,
    now: Date,
    calendar: Calendar = .current
  ) -> Bool {
    guard !isCompleted, let deadline else { return false }
    let startOfToday = calendar.startOfDay(for: now)
    let deadlineDay = calendar.startOfDay(for: deadline)
    return deadlineDay >= startOfToday
  }

  /// Fire one hour before the end of the deadline calendar day, but not before `now + minimumLeadTime`.
  static func fireDate(
    for deadline: Date,
    now: Date,
    minimumLeadTime: TimeInterval = 60,
    oneHourBeforeEndOfDay: TimeInterval = 3_600,
    calendar: Calendar = .current
  ) -> Date? {
    let window = deadlineWindow(for: deadline, calendar: calendar)
    let startOfToday = calendar.startOfDay(for: now)
    guard window.deadlineDay >= startOfToday else { return nil }

    let preferred = window.endOfDeadlineDay.addingTimeInterval(-oneHourBeforeEndOfDay)
    let earliest = now.addingTimeInterval(minimumLeadTime)
    let fire = max(preferred, earliest)

    guard fire <= window.endOfDeadlineDay else { return nil }
    return fire
  }
}
