//
//  MockTaskRepository.swift
//  FocusUp
//

import Foundation

@MainActor
final class MockTaskRepository: TaskRepository {
  var tasks: [Task]
  var saveCallCount = 0
  var createCallCount = 0
  var deleteCallCount = 0
  var error: Error?

  init(tasks: [Task] = []) {
    self.tasks = tasks
  }

  func fetchAll() async throws -> [Task] {
    if let error { throw error }
    return tasks
  }

  func fetch(id: UUID) async throws -> Task? {
    if let error { throw error }
    return tasks.first { $0.id == id }
  }

  func create(_ task: Task) async throws {
    if let error { throw error }
    try TaskValidation.validate(task)
    createCallCount += 1
    tasks.append(task)
  }

  func update(_ task: Task) async throws {
    if let error { throw error }
    try TaskValidation.validate(task)
    saveCallCount += 1
    if let index = tasks.firstIndex(where: { $0.id == task.id }) {
      tasks[index] = task
    } else {
      tasks.append(task)
    }
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
    if let error { throw error }
    deleteCallCount += 1
    tasks.removeAll { $0.id == id }
  }
}
