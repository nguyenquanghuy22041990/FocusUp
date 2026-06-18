//
//  UserPreferences.swift
//  FocusUp
//

import Foundation

struct UserPreferences: Identifiable, Codable, Equatable, Sendable {
  static let singletonID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

  let id: UUID
  var prefersReducedMotion: Bool
  var voiceOverHintsEnabled: Bool
  var hapticsEnabled: Bool
  var notifications: NotificationPreferences
  var createdAt: Date
  var updatedAt: Date

  init(
    id: UUID = UserPreferences.singletonID,
    prefersReducedMotion: Bool = false,
    voiceOverHintsEnabled: Bool = true,
    hapticsEnabled: Bool = true,
    notifications: NotificationPreferences = .default,
    createdAt: Date = .now,
    updatedAt: Date = .now
  ) {
    self.id = id
    self.prefersReducedMotion = prefersReducedMotion
    self.voiceOverHintsEnabled = voiceOverHintsEnabled
    self.hapticsEnabled = hapticsEnabled
    self.notifications = notifications
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
