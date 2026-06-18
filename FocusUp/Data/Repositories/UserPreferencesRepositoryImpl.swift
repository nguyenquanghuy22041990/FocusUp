//
//  UserPreferencesRepositoryImpl.swift
//  FocusUp
//

import Foundation
import SwiftData

@MainActor
final class UserPreferencesRepositoryImpl: UserPreferencesRepository {
  private let context: ModelContext

  init(context: ModelContext) {
    self.context = context
  }

  func fetch() async throws -> UserPreferences {
    let singletonID = UserPreferences.singletonID
    let descriptor = FetchDescriptor<UserPreferencesEntity>(
      predicate: #Predicate { $0.id == singletonID }
    )

    if let entity = try context.fetch(descriptor).first {
      return UserPreferencesMapper.toDomain(entity)
    }

    let defaults = UserPreferences()
    _ = UserPreferencesMapper.toEntity(defaults, context: context)
    try context.save()
    return defaults
  }

  func save(_ preferences: UserPreferences) async throws {
    _ = UserPreferencesMapper.toEntity(preferences, context: context)
    try context.save()
  }
}
