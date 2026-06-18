//
//  PersistenceController.swift
//  FocusUp
//

import SwiftData
import SwiftUI

enum PersistenceError: Error {
  case failedToCreateContainer(Error)
}

/// Owns the SwiftData `ModelContainer` and primary `ModelContext`.
@MainActor
final class PersistenceController {
  let container: ModelContainer
  private(set) var mainContext: ModelContext

  init(inMemory: Bool = false) throws {
    let configuration = ModelConfiguration(
      isStoredInMemoryOnly: inMemory
    )

    do {
      let container = try ModelContainer(
        for: PersistenceSchema.schema,
        configurations: [configuration]
      )
      self.container = container
      self.mainContext = ModelContext(container)
    } catch {
      throw PersistenceError.failedToCreateContainer(error)
    }
  }

  func makeContext() -> ModelContext {
    ModelContext(container)
  }

  func saveMainContext() throws {
    guard mainContext.hasChanges else { return }
    try mainContext.save()
  }
}

// MARK: - Shared instances

extension PersistenceController {
  private static func makeShared(inMemory: Bool) -> PersistenceController {
    do {
      return try PersistenceController(inMemory: inMemory)
    } catch {
      fatalError("Failed to create PersistenceController: \(error)")
    }
  }

  static let shared = makeShared(inMemory: false)

  static let preview: PersistenceController = {
    let controller = makeShared(inMemory: true)
    PreviewSampleData.seed(into: controller.mainContext)
  return controller
  }()

  static let testing = makeShared(inMemory: true)
}

// MARK: - Environment

private struct ModelContextKey: EnvironmentKey {
  @MainActor
  static var defaultValue: ModelContext {
    PersistenceController.preview.mainContext
  }
}

extension EnvironmentValues {
  var modelContext: ModelContext {
    get { self[ModelContextKey.self] }
    set { self[ModelContextKey.self] = newValue }
  }
}
