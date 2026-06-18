//
//  TaskMilestoneMapper.swift
//  FocusUp
//

import Foundation
import SwiftData

enum TaskMilestoneMapper {
  static func toDomain(_ entity: TaskMilestoneEntity) -> TaskMilestone {
    TaskMilestone(
      id: entity.id,
      title: entity.title,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt
    )
  }

  static func toEntity(
    _ domain: TaskMilestone,
    task: TaskEntity,
    context: ModelContext
  ) -> TaskMilestoneEntity {
    let entity = TaskMilestoneEntity(
      id: domain.id,
      title: domain.title,
      isCompleted: domain.isCompleted,
      createdAt: domain.createdAt,
      updatedAt: domain.updatedAt
    )
    entity.task = task
    context.insert(entity)
    return entity
  }

  static func updateEntity(_ entity: TaskMilestoneEntity, from domain: TaskMilestone) {
    entity.title = domain.title
    entity.isCompleted = domain.isCompleted
    entity.updatedAt = .now
  }
}
