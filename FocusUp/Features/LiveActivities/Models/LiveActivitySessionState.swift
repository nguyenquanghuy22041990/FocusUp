//
//  LiveActivitySessionState.swift
//  FocusUp
//

import Foundation

enum LiveActivitySessionState: String, Codable, Hashable, Sendable {
  case running
  case paused
  case completed
}
