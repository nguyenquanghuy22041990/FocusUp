//
//  SessionTimerRestorationSnapshot.swift
//  FocusUp
//

import Foundation

/// Shared session + timer snapshot for SceneStorage restoration.
struct SessionTimerRestorationSnapshot: Codable, Equatable, Sendable {
  var sessionID: UUID
  var timerSnapshot: TimerSnapshot
  var savedAt: Date

  init(sessionID: UUID, timerSnapshot: TimerSnapshot, savedAt: Date = .now) {
    self.sessionID = sessionID
    self.timerSnapshot = timerSnapshot
    self.savedAt = savedAt
  }
}

typealias FocusTimerRestorationSnapshot = SessionTimerRestorationSnapshot
typealias RestTimerRestorationSnapshot = SessionTimerRestorationSnapshot
