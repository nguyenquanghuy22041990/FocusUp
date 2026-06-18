//
//  FocusSessionStatus.swift
//  FocusUp
//

import Foundation

enum FocusSessionStatus: String, Codable, CaseIterable, Sendable {
  case planned
  case active
  case paused
  case completed
  case cancelled

  var isTerminal: Bool {
    self == .completed || self == .cancelled
  }

  var isActiveLifecycle: Bool {
    self == .active || self == .paused
  }
}

/// Backward-compatible alias for existing call sites.
typealias FocusSessionState = FocusSessionStatus
