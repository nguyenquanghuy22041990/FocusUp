//
//  PreviewTaskRepository.swift
//  FocusUp
//

import Foundation

@MainActor
final class PreviewTaskRepository: TaskRepository {
  private var tasks = PreviewSampleData.sampleTasks

  func fetchAll() async throws -> [Task] { tasks }

  func fetch(id: UUID) async throws -> Task? {
    tasks.first { $0.id == id }
  }

  func create(_ task: Task) async throws {
    try TaskValidation.validate(task)
    tasks.append(task)
  }

  func update(_ task: Task) async throws {
    try TaskValidation.validate(task)
    guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
      tasks.append(task)
      return
    }
    tasks[index] = task
  }

  func save(_ task: Task) async throws {
    if tasks.contains(where: { $0.id == task.id }) {
      try await update(task)
    } else {
      try await create(task)
    }
  }

  func updateMilestone(taskID: UUID, milestone: TaskMilestone) async throws {
    guard var task = try await fetch(id: taskID) else { return }
    if let index = task.milestones.firstIndex(where: { $0.id == milestone.id }) {
      task.milestones[index] = milestone
    } else {
      task.milestones.append(milestone)
    }
    try await update(task)
  }

  func delete(id: UUID) async throws {
    tasks.removeAll { $0.id == id }
  }
}
