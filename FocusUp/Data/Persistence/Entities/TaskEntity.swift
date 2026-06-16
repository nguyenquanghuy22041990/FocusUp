//
//  TaskEntity.swift
//  FocusUp
//

import Foundation
import SwiftData

@Model
final class TaskEntity {
  @Attribute(.unique) var id: UUID
  var title: String
  var notes: String
  var purpose: String
  var hobbies: String
  var deadline: Date?
  var priorityRawValue: String
  var statusRawValue: String
  var isCompleted: Bool
  var createdAt: Date
  var updatedAt: Date

  @Relationship(deleteRule: .cascade, inverse: \TaskMilestoneEntity.task)
  var milestones: [TaskMilestoneEntity]

  init(
    id: UUID = UUID(),
    title: String,
    notes: String = "",
    purpose: String = "",
    hobbies: String = "",
    deadline: Date? = nil,
    priorityRawValue: String = TaskPriority.medium.rawValue,
    statusRawValue: String = TaskStatus.todo.rawValue,
    isCompleted: Bool = false,
    milestones: [TaskMilestoneEntity] = [],
    createdAt: Date = .now,
    updatedAt: Date = .now
  ) {
    self.id = id
    self.title = title
    self.notes = notes
    self.purpose = purpose
    self.hobbies = hobbies
    self.deadline = deadline
    self.priorityRawValue = priorityRawValue
    self.statusRawValue = statusRawValue
    self.isCompleted = isCompleted
    self.milestones = milestones
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
