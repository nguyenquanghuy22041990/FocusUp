//
//  TaskRepositoryTests.swift
//  FocusUp
//

import Testing
@testable import FocusUp

@MainActor
struct TaskRepositoryTests {
  @Test(.tags(.persistence))
  func crudLifecycle() async throws {
    let repositories = try RepositoryTestHarness.makeRepositories()
    let repository = repositories.taskRepository

    var task = DomainFixtures.task(title: "Write tests")
    try await repository.create(task)

    let saved = try await repository.fetch(id: task.id)
    #expect(saved?.title == "Write tests")

    task.title = "Write persistence tests"
    try await repository.update(task)

    let all = try await repository.fetchAll()
    #expect(all.contains { $0.id == task.id && $0.title == "Write persistence tests" })

    try await repository.delete(id: task.id)
    let deleted = try await repository.fetch(id: task.id)
    #expect(deleted == nil)
  }

  @Test(.tags(.persistence, .tasks))
  func updateRemovesDeletedMilestones() async throws {
    let repositories = try RepositoryTestHarness.makeRepositories()
    let repository = repositories.taskRepository

    let keep = TaskMilestone(title: "Keep")
    let remove = TaskMilestone(title: "Remove")
    var task = DomainFixtures.task(title: "Milestone sync")
    task.milestones = [keep, remove]
    try await repository.create(task)

    task.milestones = [keep]
    try await repository.update(task)

    let fetched = try await repository.fetch(id: task.id)
    #expect(fetched?.milestones.count == 1)
    #expect(fetched?.milestones.first?.id == keep.id)
  }
}
