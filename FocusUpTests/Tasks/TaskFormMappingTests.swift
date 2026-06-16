//
//  TaskFormMappingTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

struct TaskFormMappingTests {
  @Test(.tags(.tasks))
  func applyAndBuildPreservesIdentity() {
    let original = Task(
      id: UUID(),
      title: "Task",
      notes: "Desc",
      purpose: "Why",
      hobbies: "Run",
      priority: .high,
      status: .inProgress,
      milestones: [TaskMilestone(title: "Step")],
      createdAt: Date(timeIntervalSince1970: 1_000)
    )

    var form = CreateTaskDraft()
    TaskFormMapping.apply(task: original, to: &form)

    let rebuilt = TaskFormMapping.buildTask(
      id: original.id,
      title: form.title,
      description: form.description,
      purpose: form.purpose,
      hobbies: form.hobbies,
      deadline: form.deadline,
      priority: form.priority,
      status: original.status,
      milestones: form.milestones,
      createdAt: original.createdAt
    )

    #expect(rebuilt.id == original.id)
    #expect(rebuilt.title == original.title)
    #expect(rebuilt.milestones.count == 1)
  }

  @Test(.tags(.tasks))
  func normalizedDeadlineClampsPastDateToToday() {
    let calendar = Calendar.current
    let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now))!
    let normalized = TaskFormMapping.normalizedDeadline(yesterday)
    #expect(normalized == calendar.startOfDay(for: .now))
  }

  @Test(.tags(.tasks))
  func normalizedDeadlineKeepsFutureDateAtStartOfDay() {
    let calendar = Calendar.current
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: .now))!
    let normalized = TaskFormMapping.normalizedDeadline(tomorrow)
    #expect(normalized == tomorrow)
  }
}
