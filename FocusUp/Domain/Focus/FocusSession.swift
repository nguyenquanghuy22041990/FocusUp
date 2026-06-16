//
//  FocusSession.swift
//  FocusUp
//

import Foundation

struct FocusSession: Identifiable, Codable, Equatable, Sendable {
  let id: UUID
  var title: String
  var plannedDurationSeconds: Int
  /// Accumulated elapsed seconds from paused/completed segments.
  var elapsedSeconds: Int
  var status: FocusSessionStatus
  /// Start of the current running segment.
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
    status: FocusSessionStatus = .planned,
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
    self.status = status
    self.segmentStartedAt = segmentStartedAt
    self.sessionStartedAt = sessionStartedAt
    self.completedAt = completedAt
    self.associatedTaskID = associatedTaskID
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
