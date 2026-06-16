//
//  UserPreferencesRepositoryTests.swift
//  FocusUp
//

import Testing
@testable import FocusUp

@MainActor
struct UserPreferencesRepositoryTests {
  @Test(.tags(.persistence))
  func fetchCreatesDefaultsWhenMissing() async throws {
    let repositories = try RepositoryTestHarness.makeRepositories()
    let repository = repositories.userPreferencesRepository

    let preferences = try await repository.fetch()
    #expect(preferences.id == UserPreferences.singletonID)
    #expect(preferences.voiceOverHintsEnabled == true)
  }

  @Test(.tags(.persistence))
  func saveAccessibilityPreferences() async throws {
    let repositories = try RepositoryTestHarness.makeRepositories()
    let repository = repositories.userPreferencesRepository

    var preferences = try await repository.fetch()
    preferences.prefersReducedMotion = true
    try await repository.save(preferences)

    let restored = try await repository.fetch()
    #expect(restored.prefersReducedMotion == true)
  }
}
