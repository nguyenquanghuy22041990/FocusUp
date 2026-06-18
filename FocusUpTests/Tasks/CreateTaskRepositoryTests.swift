//
//  CreateTaskRepositoryTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct CreateTaskRepositoryTests {
  @Test(.tags(.tasks, .persistence))
  func createPersistsExtendedFields() async throws {
    let repositories = try RepositoryTestHarness.makeRepositories()
    let repository = repositories.taskRepository

    let deadline = Calendar.current.date(byAdding: .day, value: 3, to: .now)!
    let task = Task(
      title: "Full task",
      notes: "Description text",
      purpose: "Stay focused",
      hobbies: "Walking",
      deadline: deadline,
      priority: .high,
      milestones: [TaskMilestone(title: "First step")]
    )

    try await repository.create(task)

    let fetched = try await repository.fetch(id: task.id)
    #expect(fetched?.purpose == "Stay focused")
    #expect(fetched?.hobbies == "Walking")
    #expect(fetched?.deadline != nil)
    #expect(fetched?.milestones.count == 1)
  }
}
