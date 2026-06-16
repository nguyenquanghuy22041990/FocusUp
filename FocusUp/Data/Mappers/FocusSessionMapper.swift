//
//  FocusSessionMapper.swift
//  FocusUp
//

import Foundation
import SwiftData

enum FocusSessionMapper {
  static func toDomain(_ entity: FocusSessionEntity) -> FocusSession {
    FocusSession(
      id: entity.id,
      title: entity.title,
      plannedDurationSeconds: entity.plannedDurationSeconds,
      elapsedSeconds: entity.elapsedSeconds,
      status: FocusSessionStatus(rawValue: entity.statusRawValue) ?? .planned,
      segmentStartedAt: entity.segmentStartedAt,
      sessionStartedAt: entity.sessionStartedAt,
      completedAt: entity.completedAt,
      associatedTaskID: entity.associatedTaskID,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt
    )
  }

  static func toEntity(_ domain: FocusSession, context: ModelContext) -> FocusSessionEntity {
    if let existing = fetchEntity(id: domain.id, context: context) {
      updateEntity(existing, from: domain)
      return existing
    }

    let entity = FocusSessionEntity(
      id: domain.id,
      title: domain.title,
      plannedDurationSeconds: domain.plannedDurationSeconds,
      elapsedSeconds: domain.elapsedSeconds,
      statusRawValue: domain.status.rawValue,
      segmentStartedAt: domain.segmentStartedAt,
      sessionStartedAt: domain.sessionStartedAt,
      completedAt: domain.completedAt,
      associatedTaskID: domain.associatedTaskID,
      createdAt: domain.createdAt,
      updatedAt: domain.updatedAt
    )
    context.insert(entity)
    return entity
  }

  static func updateEntity(_ entity: FocusSessionEntity, from domain: FocusSession) {
    entity.title = domain.title
    entity.plannedDurationSeconds = domain.plannedDurationSeconds
    entity.elapsedSeconds = domain.elapsedSeconds
    entity.statusRawValue = domain.status.rawValue
    entity.segmentStartedAt = domain.segmentStartedAt
    entity.sessionStartedAt = domain.sessionStartedAt
    entity.completedAt = domain.completedAt
    entity.associatedTaskID = domain.associatedTaskID
    entity.updatedAt = .now
  }

  private static func fetchEntity(id: UUID, context: ModelContext) -> FocusSessionEntity? {
    let descriptor = FetchDescriptor<FocusSessionEntity>(
      predicate: #Predicate { $0.id == id }
    )
    return try? context.fetch(descriptor).first
  }
}
