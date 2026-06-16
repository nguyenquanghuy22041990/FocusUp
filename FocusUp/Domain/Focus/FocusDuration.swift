//
//  FocusDuration.swift
//  FocusUp
//

import Foundation

struct FocusDuration: Codable, Equatable, Sendable {
  let plannedSeconds: Int
  let elapsedSeconds: Int

  var remainingSeconds: Int {
    max(0, plannedSeconds - elapsedSeconds)
  }

  var progress: Double {
    guard plannedSeconds > 0 else { return 0 }
    return min(1, Double(elapsedSeconds) / Double(plannedSeconds))
  }

  init(plannedSeconds: Int, elapsedSeconds: Int = 0) {
    self.plannedSeconds = max(0, plannedSeconds)
    self.elapsedSeconds = max(0, elapsedSeconds)
  }

  static func from(session: FocusSession, at date: Date = .now) -> FocusDuration {
    FocusDuration(
      plannedSeconds: session.plannedDurationSeconds,
      elapsedSeconds: session.elapsedSeconds(at: date)
    )
  }
}
