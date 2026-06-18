//
//  TaskRepositoryFeatureTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

@MainActor
struct TaskRepositoryFeatureTests {
  @Test(.tags(.tasks, .persistence))
  func updateMilestonePersistsChange() async throws {
    let repositories = try RepositoryTestHarness.makeRepositories()
    let repository = repositories.taskRepository

    var task = DomainFixtures.task(title: "Milestone task")
    task.milestones = [TaskMilestone(title: "Step 1")]
    try await repository.create(task)

    var milestone = task.milestones[0]
    milestone.isCompleted = true
    try await repository.updateMilestone(taskID: task.id, milestone: milestone)

    let fetched = try await repository.fetch(id: task.id)
    #expect(fetched?.milestones.first?.isCompleted == true)
  }
}
