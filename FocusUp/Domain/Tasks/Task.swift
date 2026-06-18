//
//  Task.swift
//  FocusUp
//

import Foundation

struct Task: Identifiable, Codable, Equatable, Sendable {
  let id: UUID
  var title: String
  var notes: String
  var purpose: String
  var hobbies: String
  var deadline: Date?
  var priority: TaskPriority
  var status: TaskStatus
  var milestones: [TaskMilestone]
  var createdAt: Date
  var updatedAt: Date

  var isCompleted: Bool {
    status.isDone
  }

  init(
    id: UUID = UUID(),
    title: String,
    notes: String = "",
    purpose: String = "",
    hobbies: String = "",
    deadline: Date? = nil,
    priority: TaskPriority = .medium,
    status: TaskStatus = .todo,
    milestones: [TaskMilestone] = [],
    createdAt: Date = .now,
    updatedAt: Date = .now
  ) {
    self.id = id
    self.title = title
    self.notes = notes
    self.purpose = purpose
    self.hobbies = hobbies
    self.deadline = deadline
    self.priority = priority
    self.status = status
    self.milestones = milestones
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  /// Convenience initializer for legacy call sites using `isCompleted`.
  init(
    id: UUID = UUID(),
    title: String,
    notes: String = "",
    isCompleted: Bool,
    milestones: [TaskMilestone] = [],
    createdAt: Date = .now,
    updatedAt: Date = .now
  ) {
    self.init(
      id: id,
      title: title,
      notes: notes,
      priority: .medium,
      status: isCompleted ? .completed : .todo,
      milestones: milestones,
      createdAt: createdAt,
      updatedAt: updatedAt
    )
  }
}
