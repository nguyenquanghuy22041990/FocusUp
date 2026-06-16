//
//  TaskMilestoneEntity.swift
//  FocusUp
//

import Foundation
import SwiftData

@Model
final class TaskMilestoneEntity {
  @Attribute(.unique) var id: UUID
  var title: String
  var isCompleted: Bool
  var createdAt: Date
  var updatedAt: Date

  var task: TaskEntity?

  init(
    id: UUID = UUID(),
    title: String,
    isCompleted: Bool = false,
    createdAt: Date = .now,
    updatedAt: Date = .now
  ) {
    self.id = id
    self.title = title
    self.isCompleted = isCompleted
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
