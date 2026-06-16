//
//  TaskFormMapping.swift
//  FocusUp
//

import Foundation

enum TaskFormMapping {
  /// Normalizes a deadline to the start of its calendar day and clamps past dates to today.
  static func normalizedDeadline(_ deadline: Date?, now: Date = .now, calendar: Calendar = .current) -> Date? {
    guard let deadline else { return nil }
    let deadlineDay = calendar.startOfDay(for: deadline)
    let startOfToday = calendar.startOfDay(for: now)
    return deadlineDay < startOfToday ? startOfToday : deadlineDay
  }

  static func milestonesToDrafts(_ milestones: [TaskMilestone]) -> [MilestoneDraft] {
    milestones.map { MilestoneDraft(id: $0.id, title: $0.title) }
  }

  static func draftsToMilestones(
    _ drafts: [MilestoneDraft],
    preserving existing: [TaskMilestone] = []
  ) -> [TaskMilestone] {
    let existingByID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })
    return drafts
      .map { draft in
        MilestoneDraft(
          id: draft.id,
          title: draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        )
      }
      .filter { !$0.title.isEmpty }
      .map { draft in
        if let match = existingByID[draft.id] {
          return TaskMilestone(
            id: draft.id,
            title: draft.title,
            isCompleted: match.isCompleted,
            createdAt: match.createdAt,
            updatedAt: .now
          )
        }
        return TaskMilestone(id: draft.id, title: draft.title)
      }
  }

  static func apply(task: Task, to form: inout CreateTaskDraft) {
    form.title = task.title
    form.description = task.notes
    form.purpose = task.purpose
    form.hobbies = task.hobbies
    form.deadline = normalizedDeadline(task.deadline)
    form.priority = task.priority
    form.milestones = milestonesToDrafts(task.milestones)
  }

  static func buildTask(
    id: UUID,
    title: String,
    description: String,
    purpose: String,
    hobbies: String,
    deadline: Date?,
    priority: TaskPriority,
    status: TaskStatus,
    milestones: [MilestoneDraft],
    existingMilestones: [TaskMilestone] = [],
    createdAt: Date,
    updatedAt: Date = .now
  ) -> Task {
    Task(
      id: id,
      title: title.trimmingCharacters(in: .whitespacesAndNewlines),
      notes: description.trimmingCharacters(in: .whitespacesAndNewlines),
      purpose: purpose.trimmingCharacters(in: .whitespacesAndNewlines),
      hobbies: hobbies.trimmingCharacters(in: .whitespacesAndNewlines),
      deadline: normalizedDeadline(deadline),
      priority: priority,
      status: status,
      milestones: draftsToMilestones(milestones, preserving: existingMilestones),
      createdAt: createdAt,
      updatedAt: updatedAt
    )
  }
}
