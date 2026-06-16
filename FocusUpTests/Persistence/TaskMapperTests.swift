//
//  TaskMapperTests.swift
//  FocusUp
//

import SwiftData
import Testing
@testable import FocusUp

@MainActor
struct TaskMapperTests {
  @Test(.tags(.persistence))
  func entityDomainRoundTripPreservesFields() throws {
    let persistence = try RepositoryTestHarness.makePersistence()
    let context = persistence.mainContext

    let original = DomainFixtures.task(title: "Mapper test")
    _ = TaskMapper.toEntity(original, context: context)
    try context.save()

    let fetched = try context.fetch(FetchDescriptor<TaskEntity>()).first!
    let mapped = TaskMapper.toDomain(fetched)

    #expect(mapped.id == original.id)
    #expect(mapped.title == original.title)
    #expect(mapped.isCompleted == original.isCompleted)
  }
}
