//
//  TimerState.swift
//  FocusUp
//

import Foundation

enum TimerState: String, Codable, Sendable, Equatable {
  case idle
  case running
  case paused
  case completed
  case cancelled
}
