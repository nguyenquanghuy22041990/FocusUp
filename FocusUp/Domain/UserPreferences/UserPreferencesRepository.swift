//
//  UserPreferencesRepository.swift
//  FocusUp
//

import Foundation

@MainActor
protocol UserPreferencesRepository {
  func fetch() async throws -> UserPreferences
  func save(_ preferences: UserPreferences) async throws
}
