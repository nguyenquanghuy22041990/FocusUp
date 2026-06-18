//
//  CreateTaskDraft.swift
//  FocusUp
//

import Foundation

/// Lightweight form draft for SceneStorage restoration (not persisted to SwiftData).
struct CreateTaskDraft: Codable, Equatable, Sendable {
  var title: String
  var description: String
  var purpose: String
  var hobbies: String
  var deadline: Date?
  var priority: TaskPriority
  var milestones: [MilestoneDraft]
  var savedAt: Date

  init(
    title: String = "",
    description: String = "",
    purpose: String = "",
    hobbies: String = "",
    deadline: Date? = nil,
    priority: TaskPriority = .medium,
    milestones: [MilestoneDraft] = [],
    savedAt: Date = .now
  ) {
    self.title = title
    self.description = description
    self.purpose = purpose
    self.hobbies = hobbies
    self.deadline = deadline
    self.priority = priority
    self.milestones = milestones
    self.savedAt = savedAt
  }

  var isEmpty: Bool {
    title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && description.isEmpty
      && purpose.isEmpty
      && hobbies.isEmpty
      && deadline == nil
      && milestones.isEmpty
  }
}

struct MilestoneDraft: Identifiable, Codable, Equatable, Sendable {
  var id: UUID
  var title: String

  init(id: UUID = UUID(), title: String = "") {
    self.id = id
    self.title = title
  }
}
