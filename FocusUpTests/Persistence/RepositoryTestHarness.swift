//
//  RepositoryTestHarness.swift
//  FocusUp
//

import SwiftData
@testable import FocusUp

@MainActor
enum RepositoryTestHarness {
  static func makePersistence() throws -> PersistenceController {
    try PersistenceController(inMemory: true)
  }

  static func makeRepositories() throws -> AppContainer.Repositories {
    let persistence = try makePersistence()
    return .live(using: persistence)
  }
}
