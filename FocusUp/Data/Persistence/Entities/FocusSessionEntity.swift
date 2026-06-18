//
//  FocusSessionEntity.swift
//  FocusUp
//

import Foundation
import SwiftData

@Model
final class FocusSessionEntity {
  @Attribute(.unique) var id: UUID
  var title: String
  var plannedDurationSeconds: Int
  var elapsedSeconds: Int
  var statusRawValue: String
  var segmentStartedAt: Date?
  var sessionStartedAt: Date?
  var completedAt: Date?
  var associatedTaskID: UUID?
  var createdAt: Date
  var updatedAt: Date

  init(
    id: UUID = UUID(),
    title: String,
    plannedDurationSeconds: Int = 25 * 60,
    elapsedSeconds: Int = 0,
    statusRawValue: String = FocusSessionStatus.planned.rawValue,
    segmentStartedAt: Date? = nil,
    sessionStartedAt: Date? = nil,
    completedAt: Date? = nil,
    associatedTaskID: UUID? = nil,
    createdAt: Date = .now,
    updatedAt: Date = .now
  ) {
    self.id = id
    self.title = title
    self.plannedDurationSeconds = plannedDurationSeconds
    self.elapsedSeconds = elapsedSeconds
    self.statusRawValue = statusRawValue
    self.segmentStartedAt = segmentStartedAt
    self.sessionStartedAt = sessionStartedAt
    self.completedAt = completedAt
    self.associatedTaskID = associatedTaskID
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
