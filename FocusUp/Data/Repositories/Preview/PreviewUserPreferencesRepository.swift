//
//  PreviewUserPreferencesRepository.swift
//  FocusUp
//

import Foundation

@MainActor
final class PreviewUserPreferencesRepository: UserPreferencesRepository {
  private var preferences = PreviewSampleData.samplePreferences

  func fetch() async throws -> UserPreferences { preferences }

  func save(_ preferences: UserPreferences) async throws {
    self.preferences = preferences
  }
}
