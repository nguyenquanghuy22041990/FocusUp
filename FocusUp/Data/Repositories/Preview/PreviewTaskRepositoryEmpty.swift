//
//  PreviewTaskRepositoryEmpty.swift
//  FocusUp
//

import Foundation

@MainActor
final class PreviewTaskRepositoryEmpty: TaskRepository {
  func fetchAll() async throws -> [Task] { [] }
  func fetch(id: UUID) async throws -> Task? { nil }

  func create(_ task: Task) async throws {
    try TaskValidation.validate(task)
  }

  func update(_ task: Task) async throws {
    try TaskValidation.validate(task)
  }

  func save(_ task: Task) async throws {
    try TaskValidation.validate(task)
  }

  func updateMilestone(taskID: UUID, milestone: TaskMilestone) async throws {}
  func delete(id: UUID) async throws {}
}
