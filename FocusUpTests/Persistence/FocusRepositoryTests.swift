//
//  FocusRepositoryTests.swift
//  FocusUp
//

import Testing
@testable import FocusUp

@MainActor
struct FocusRepositoryTests {
  @Test(.tags(.persistence))
  func saveAndFetchActiveSession() async throws {
    let repositories = try RepositoryTestHarness.makeRepositories()
    let repository = repositories.focusRepository

    let session = DomainFixtures.focusSession(title: "Active", status: .active)
    try await repository.save(session)

    let active = try await repository.fetchActive()
    #expect(active?.id == session.id)
    #expect(active?.status == .active)
  }

  @Test(.tags(.persistence))
  func fetchCompletedAndStatistics() async throws {
    let repositories = try RepositoryTestHarness.makeRepositories()
    let repository = repositories.focusRepository

    var completed = DomainFixtures.focusSession(title: "Done", status: .completed)
    completed.elapsedSeconds = 25 * 60
    try await repository.save(completed)

    let fetched = try await repository.fetchCompleted()
    #expect(fetched.contains { $0.id == completed.id })

    let stats = try await repository.fetchStatistics()
    #expect(stats.completedSessionCount >= 1)
    #expect(stats.totalFocusSeconds >= 25 * 60)
  }
}
