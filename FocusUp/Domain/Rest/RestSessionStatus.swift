//
//  RestSessionStatus.swift
//  FocusUp
//

import Foundation

enum RestSessionStatus: String, Codable, CaseIterable, Sendable {
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
