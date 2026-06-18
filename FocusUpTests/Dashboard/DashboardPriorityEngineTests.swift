//
//  DashboardPriorityEngineTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

struct DashboardPriorityEngineTests {
  @Test(.tags(.dashboard))
  func overdueTaskRanksHighest() {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let overdue = Task(
      title: "Overdue",
      deadline: now.addingTimeInterval(-3_600),
      priority: .low,
      status: .todo
    )
    let soon = Task(
      title: "Due soon",
      deadline: now.addingTimeInterval(3_600),
      priority: .low,
      status: .todo
    )

    let results = DashboardPriorityEngine.recommendations(from: [soon, overdue], now: now)
    #expect(results.first?.taskID == overdue.id)
    #expect(results.first?.urgencyScore ?? 0 > results.last?.urgencyScore ?? 0)
  }

  @Test(.tags(.dashboard))
  func completedTasksExcluded() {
    let done = Task(title: "Done", status: .completed)
    let results = DashboardPriorityEngine.recommendations(from: [done])
    #expect(results.isEmpty)
  }

  @Test(.tags(.dashboard))
  func inProgressTaskSurfaces() {
    let task = Task(title: "Active", status: .inProgress)
    let results = DashboardPriorityEngine.recommendations(from: [task])
    #expect(results.count == 1)
    #expect(results[0].title == "Active")
  }
}
