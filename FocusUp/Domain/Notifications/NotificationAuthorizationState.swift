//
//  NotificationAuthorizationState.swift
//  FocusUp
//

import Foundation

enum NotificationAuthorizationState: String, Equatable, Sendable {
  case notDetermined
  case denied
  case authorized
  case provisional
  case ephemeral

  var canScheduleNotifications: Bool {
    self == .authorized || self == .provisional || self == .ephemeral
  }

  var needsPermissionEducation: Bool {
    self == .notDetermined
  }

  var needsSettingsRecovery: Bool {
    self == .denied
  }
}
