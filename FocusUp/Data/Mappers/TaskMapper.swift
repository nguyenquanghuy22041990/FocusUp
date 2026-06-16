//
//  TaskMapper.swift
//  FocusUp
//

import Foundation
import SwiftData

enum TaskMapper {
  static func toDomain(_ entity: TaskEntity) -> Task {
    let status = TaskStatus(rawValue: entity.statusRawValue) ?? (entity.isCompleted ? .completed : .todo)
    return Task(
      id: entity.id,
      title: entity.title,
      notes: entity.notes,
      purpose: entity.purpose,
      hobbies: entity.hobbies,
      deadline: entity.deadline,
      priority: TaskPriority(rawValue: entity.priorityRawValue) ?? .medium,
      status: status,
      milestones: entity.milestones.map(TaskMilestoneMapper.toDomain),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt
    )
  }

  static func toEntity(_ domain: Task, context: ModelContext) -> TaskEntity {
    if let existing = fetchEntity(id: domain.id, context: context) {
      updateEntity(existing, from: domain, context: context)
      return existing
    }

    let entity = TaskEntity(
      id: domain.id,
      title: domain.title,
      notes: domain.notes,
      purpose: domain.purpose,
      hobbies: domain.hobbies,
      deadline: domain.deadline,
      priorityRawValue: domain.priority.rawValue,
      statusRawValue: domain.status.rawValue,
      isCompleted: domain.isCompleted,
      createdAt: domain.createdAt,
      updatedAt: domain.updatedAt
    )
    context.insert(entity)
    syncMilestones(for: entity, from: domain, context: context)
    return entity
  }

  static func updateEntity(_ entity: TaskEntity, from domain: Task, context: ModelContext) {
    entity.title = domain.title
    entity.notes = domain.notes
    entity.purpose = domain.purpose
    entity.hobbies = domain.hobbies
    entity.deadline = domain.deadline
    entity.priorityRawValue = domain.priority.rawValue
    entity.statusRawValue = domain.status.rawValue
    entity.isCompleted = domain.isCompleted
    entity.updatedAt = .now
    syncMilestones(for: entity, from: domain, context: context)
  }

  private static func syncMilestones(
    for entity: TaskEntity,
    from domain: Task,
    context: ModelContext
  ) {
    let existingByID = Dictionary(uniqueKeysWithValues: entity.milestones.map { ($0.id, $0) })
    var updated: [TaskMilestoneEntity] = []

    let retainedIDs = Set(domain.milestones.map(\.id))
    for existing in entity.milestones where !retainedIDs.contains(existing.id) {
      context.delete(existing)
    }

    for milestone in domain.milestones {
      if let existing = existingByID[milestone.id] {
        TaskMilestoneMapper.updateEntity(existing, from: milestone)
        updated.append(existing)
      } else {
        let created = TaskMilestoneMapper.toEntity(milestone, task: entity, context: context)
        updated.append(created)
      }
    }

    entity.milestones = updated
  }

  private static func fetchEntity(id: UUID, context: ModelContext) -> TaskEntity? {
    let descriptor = FetchDescriptor<TaskEntity>(
      predicate: #Predicate { $0.id == id }
    )
    return try? context.fetch(descriptor).first
  }
}
