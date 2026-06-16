//
//  TaskMilestone.swift
//  FocusUp
//

import Foundation

struct TaskMilestone: Identifiable, Codable, Equatable, Sendable {
  let id: UUID
  var title: String
  var isCompleted: Bool
  var createdAt: Date
  var updatedAt: Date

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
