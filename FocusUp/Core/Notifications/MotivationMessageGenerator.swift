//
//  MotivationMessageGenerator.swift
//  FocusUp
//

import Foundation

enum MotivationContext: Equatable, Sendable {
  case dailyEncouragement
  case focusReminder
  case taskDeadline(title: String)
  case sessionComplete(title: String)
  case streak(days: Int)
}

struct MotivationMessage: Equatable, Sendable {
  var title: String
  var body: String
}

enum MotivationMessageGenerator {
  private static let dailyBodies = [
    "A short focus block is enough to begin. No pressure.",
    "Pick one small task and give it your calm attention.",
    "Your pace is valid. Start gently when you're ready.",
    "Five mindful minutes can shift the whole day.",
  ]

  private static let focusReminderBodies = [
    "When you're ready, a focus session is here for you.",
    "A quiet moment of focus might feel good right now.",
    "Return to one task—no rush, just intention.",
  ]

  private static let sessionCompleteBodies = [
    "You showed up. Take a breath before what's next.",
    "Session complete. Let that count.",
    "Well done. Rest is part of the work too.",
  ]

  private static let streakBodies = [
    "Your streak reflects steady care, not pressure.",
    "Consistency in small steps—that's the rhythm.",
    "Day by day adds up. Keep it kind.",
  ]

  static func message(
    for context: MotivationContext,
    seed: Date = .now,
    calendar: Calendar = .current
  ) -> MotivationMessage {
    switch context {
    case .dailyEncouragement:
      return MotivationMessage(
        title: "A gentle nudge",
        body: pick(from: dailyBodies, seed: seed, salt: 1, calendar: calendar)
      )
    case .focusReminder:
      return MotivationMessage(
        title: "Focus when you're ready",
        body: pick(from: focusReminderBodies, seed: seed, salt: 2, calendar: calendar)
      )
    case .taskDeadline(let title):
      return MotivationMessage(
        title: "Upcoming: \(title)",
        body: "Your deadline is approaching. One focused block could help."
      )
    case .sessionComplete(let title):
      return MotivationMessage(
        title: "Focus complete",
        body: "\(title). \(pick(from: sessionCompleteBodies, seed: seed, salt: 3, calendar: calendar))"
      )
    case .streak(let days):
      let body = days > 0
        ? "\(days)-day streak. \(pick(from: streakBodies, seed: seed, salt: 4, calendar: calendar))"
        : "Your next session can start a calm streak."
      return MotivationMessage(
        title: days > 0 ? "\(days)-day streak" : "Ready when you are",
        body: body
      )
    }
  }

  private static func pick(
    from pool: [String],
    seed: Date,
    salt: Int,
    calendar: Calendar
  ) -> String {
    guard !pool.isEmpty else { return "" }
    let day = calendar.ordinality(of: .day, in: .year, for: seed) ?? 0
    let index = (day + salt) % pool.count
    return pool[index]
  }
}
