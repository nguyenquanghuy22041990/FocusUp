//
//  Clock.swift
//  FocusUp
//

import Foundation

/// Injectable clock for deterministic timer tests.
protocol Clock: Sendable {
  func now() -> Date
}

struct SystemClock: Clock {
  func now() -> Date { Date() }
}

final class TestClock: Clock, @unchecked Sendable {
  private var current: Date

  init(startingAt date: Date = Date(timeIntervalSince1970: 1_000_000)) {
    current = date
  }

  func now() -> Date { current }

  func advance(by interval: TimeInterval) {
    current = current.addingTimeInterval(interval)
  }

  func set(to date: Date) {
    current = date
  }
}
