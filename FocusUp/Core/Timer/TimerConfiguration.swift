//
//  TimerConfiguration.swift
//  FocusUp
//

import Foundation

struct TimerConfiguration: Codable, Equatable, Sendable {
  var totalDurationSeconds: Int

  init(totalDurationSeconds: Int) {
    self.totalDurationSeconds = max(0, totalDurationSeconds)
  }

  static let defaultFocus = TimerConfiguration(totalDurationSeconds: 25 * 60)
}
