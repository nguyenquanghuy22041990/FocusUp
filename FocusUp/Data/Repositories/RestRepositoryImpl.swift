//
//  RestRepositoryImpl.swift
//  FocusUp
//

import Foundation
import SwiftData

@MainActor
final class RestRepositoryImpl: RestRepository {
  private let context: ModelContext

  init(context: ModelContext) {
    self.context = context
  }

  func fetchAll() async throws -> [RestSession] {
    let descriptor = FetchDescriptor<RestSessionEntity>(
      sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
    )
    return try context.fetch(descriptor).map(RestSessionMapper.toDomain)
  }

  func fetch(id: UUID) async throws -> RestSession? {
    let descriptor = FetchDescriptor<RestSessionEntity>(
      predicate: #Predicate { $0.id == id }
    )
    return try context.fetch(descriptor).first.map(RestSessionMapper.toDomain)
  }

  func fetchActive() async throws -> RestSession? {
    let active = RestSessionStatus.active.rawValue
    let paused = RestSessionStatus.paused.rawValue
    let descriptor = FetchDescriptor<RestSessionEntity>(
      predicate: #Predicate {
        $0.statusRawValue == active || $0.statusRawValue == paused
      },
      sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
    )
    return try context.fetch(descriptor).first.map(RestSessionMapper.toDomain)
  }

  func save(_ session: RestSession) async throws {
    _ = RestSessionMapper.toEntity(session, context: context)
    try context.save()
  }

  func delete(id: UUID) async throws {
    let descriptor = FetchDescriptor<RestSessionEntity>(
      predicate: #Predicate { $0.id == id }
    )
    if let entity = try context.fetch(descriptor).first {
      context.delete(entity)
      try context.save()
    }
  }
}
