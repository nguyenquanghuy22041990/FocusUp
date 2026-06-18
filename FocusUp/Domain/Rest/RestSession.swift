//
//  RestSession.swift
//  FocusUp
//

import Foundation

struct RestSession: Identifiable, Codable, Equatable, Sendable {
  let id: UUID
  var title: String
  var plannedDurationSeconds: Int
  var elapsedSeconds: Int
  var status: RestSessionStatus
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
    status: RestSessionStatus = .planned,
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
    self.status = status
    self.segmentStartedAt = segmentStartedAt
    self.sessionStartedAt = sessionStartedAt
    self.completedAt = completedAt
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
