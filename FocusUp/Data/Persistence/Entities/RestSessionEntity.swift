//
//  RestSessionEntity.swift
//  FocusUp
//

import Foundation
import SwiftData

@Model
final class RestSessionEntity {
  @Attribute(.unique) var id: UUID
  var title: String
  var plannedDurationSeconds: Int
  var elapsedSeconds: Int
  var statusRawValue: String
  var segmentStartedAt: Date?
  var sessionStartedAt: Date?
  var completedAt: Date?
  var createdAt: Date
  var updatedAt: Date

  init(
    id: UUID = UUID(),
    title: String = "Rest Break",
    plannedDurationSeconds: Int = 15 * 60,
    elapsedSeconds: Int = 0,
    statusRawValue: String = RestSessionStatus.planned.rawValue,
    segmentStartedAt: Date? = nil,
    sessionStartedAt: Date? = nil,
    completedAt: Date? = nil,
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
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
