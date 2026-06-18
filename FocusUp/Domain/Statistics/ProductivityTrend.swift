//
//  ProductivityTrend.swift
//  FocusUp
//

import Foundation

struct ProductivityTrend: Equatable, Sendable {
  enum Direction: String, Sendable, Codable {
    case up
    case down
    case stable
  }

  var direction: Direction
  /// Week-over-week change in focus minutes (-100...100+).
  var weekOverWeekPercent: Int
  var insight: String

  static let empty = ProductivityTrend(
    direction: .stable,
    weekOverWeekPercent: 0,
    insight: "Complete a few sessions to see how your rhythm evolves."
  )
}
