//
//  RestSessionMapper.swift
//  FocusUp
//

import Foundation
import SwiftData

enum RestSessionMapper {
  static func toDomain(_ entity: RestSessionEntity) -> RestSession {
    RestSession(
      id: entity.id,
      title: entity.title,
      plannedDurationSeconds: entity.plannedDurationSeconds,
      elapsedSeconds: entity.elapsedSeconds,
      status: RestSessionStatus(rawValue: entity.statusRawValue) ?? .planned,
      segmentStartedAt: entity.segmentStartedAt,
      sessionStartedAt: entity.sessionStartedAt,
      completedAt: entity.completedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt
    )
  }

  static func toEntity(_ domain: RestSession, context: ModelContext) -> RestSessionEntity {
    if let existing = fetchEntity(id: domain.id, context: context) {
      updateEntity(existing, from: domain)
      return existing
    }

    let entity = RestSessionEntity(
      id: domain.id,
      title: domain.title,
      plannedDurationSeconds: domain.plannedDurationSeconds,
      elapsedSeconds: domain.elapsedSeconds,
      statusRawValue: domain.status.rawValue,
      segmentStartedAt: domain.segmentStartedAt,
      sessionStartedAt: domain.sessionStartedAt,
      completedAt: domain.completedAt,
      createdAt: domain.createdAt,
      updatedAt: domain.updatedAt
    )
    context.insert(entity)
    return entity
  }

  static func updateEntity(_ entity: RestSessionEntity, from domain: RestSession) {
    entity.title = domain.title
    entity.plannedDurationSeconds = domain.plannedDurationSeconds
    entity.elapsedSeconds = domain.elapsedSeconds
    entity.statusRawValue = domain.status.rawValue
    entity.segmentStartedAt = domain.segmentStartedAt
    entity.sessionStartedAt = domain.sessionStartedAt
    entity.completedAt = domain.completedAt
    entity.updatedAt = .now
  }

  private static func fetchEntity(id: UUID, context: ModelContext) -> RestSessionEntity? {
    let descriptor = FetchDescriptor<RestSessionEntity>(
      predicate: #Predicate { $0.id == id }
    )
    return try? context.fetch(descriptor).first
  }
}
