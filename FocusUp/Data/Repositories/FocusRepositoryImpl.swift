//
//  FocusRepositoryImpl.swift
//  FocusUp
//

import Foundation
import SwiftData

@MainActor
final class FocusRepositoryImpl: FocusRepository {
  private let context: ModelContext

  init(context: ModelContext) {
    self.context = context
  }

  func fetchAll() async throws -> [FocusSession] {
    let descriptor = FetchDescriptor<FocusSessionEntity>(
      sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
    )
    return try context.fetch(descriptor).map(FocusSessionMapper.toDomain)
  }

  func fetch(id: UUID) async throws -> FocusSession? {
    let descriptor = FetchDescriptor<FocusSessionEntity>(
      predicate: #Predicate { $0.id == id }
    )
    return try context.fetch(descriptor).first.map(FocusSessionMapper.toDomain)
  }

  func fetchActive() async throws -> FocusSession? {
    let active = FocusSessionStatus.active.rawValue
    let paused = FocusSessionStatus.paused.rawValue
    let descriptor = FetchDescriptor<FocusSessionEntity>(
      predicate: #Predicate {
        $0.statusRawValue == active || $0.statusRawValue == paused
      },
      sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
    )
    return try context.fetch(descriptor).first.map(FocusSessionMapper.toDomain)
  }

  func fetchCompleted() async throws -> [FocusSession] {
    let completed = FocusSessionStatus.completed.rawValue
    let descriptor = FetchDescriptor<FocusSessionEntity>(
      predicate: #Predicate { $0.statusRawValue == completed },
      sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
    )
    return try context.fetch(descriptor).map(FocusSessionMapper.toDomain)
  }

  func fetchStatistics() async throws -> FocusStatistics {
    let sessions = try await fetchAll()
    let completed = sessions.filter { $0.status == .completed }
    let active = sessions.filter { $0.status.isActiveLifecycle }
    let totalSeconds = completed.reduce(0) { $0 + $1.elapsedSeconds }

    return FocusStatistics(
      totalFocusSeconds: totalSeconds,
      completedSessionCount: completed.count,
      activeSessionCount: active.count,
      totalSessionCount: sessions.count
    )
  }

  func save(_ session: FocusSession) async throws {
    _ = FocusSessionMapper.toEntity(session, context: context)
    try context.save()
  }

  func delete(id: UUID) async throws {
    let descriptor = FetchDescriptor<FocusSessionEntity>(
      predicate: #Predicate { $0.id == id }
    )
    if let entity = try context.fetch(descriptor).first {
      context.delete(entity)
      try context.save()
    }
  }
}
