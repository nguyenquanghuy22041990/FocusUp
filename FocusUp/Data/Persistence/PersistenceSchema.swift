//
//  PersistenceSchema.swift
//  FocusUp
//

import SwiftData

enum PersistenceSchema {
  static let models: [any PersistentModel.Type] = [
    TaskEntity.self,
    TaskMilestoneEntity.self,
    FocusSessionEntity.self,
    RestSessionEntity.self,
    UserPreferencesEntity.self
  ]

  static var schema: Schema {
    Schema(models)
  }
}
