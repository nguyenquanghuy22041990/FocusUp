//
//  TaskRepositoryImpl.swift
//  FocusUp
//

import Foundation
import SwiftData

@MainActor
final class TaskRepositoryImpl: TaskRepository {
  private let context: ModelContext

  init(context: ModelContext) {
    self.context = context
  }

  func fetchAll() async throws -> [Task] {
    let descriptor = FetchDescriptor<TaskEntity>(
      sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
    )
    return try context.fetch(descriptor).map(TaskMapper.toDomain)
  }

  func fetch(id: UUID) async throws -> Task? {
    let descriptor = FetchDescriptor<TaskEntity>(
      predicate: #Predicate { $0.id == id }
    )
    return try context.fetch(descriptor).first.map(TaskMapper.toDomain)
  }

  func create(_ task: Task) async throws {
    try TaskValidation.validate(task)
    _ = TaskMapper.toEntity(task, context: context)
    try context.save()
  }

  func update(_ task: Task) async throws {
    try TaskValidation.validate(task)
    guard let entity = fetchEntity(id: task.id) else {
      try await create(task)
      return
    }
    TaskMapper.updateEntity(entity, from: task, context: context)
    try context.save()
  }

  func save(_ task: Task) async throws {
    if fetchEntity(id: task.id) != nil {
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
    task.updatedAt = .now
    try await update(task)
  }

  func delete(id: UUID) async throws {
    let descriptor = FetchDescriptor<TaskEntity>(
      predicate: #Predicate { $0.id == id }
    )
    if let entity = try context.fetch(descriptor).first {
      context.delete(entity)
      try context.save()
    }
  }

  private func fetchEntity(id: UUID) -> TaskEntity? {
    let descriptor = FetchDescriptor<TaskEntity>(
      predicate: #Predicate { $0.id == id }
    )
    return try? context.fetch(descriptor).first
  }
}
