//
//  MotivationMessageGeneratorTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@Suite(.tags(.notifications))
struct MotivationMessageGeneratorTests {
  @Test func dailyMessageIsDeterministicForSameDay() {
    let seed = Date(timeIntervalSince1970: 1_700_000_000)
    let first = MotivationMessageGenerator.message(for: .dailyEncouragement, seed: seed)
    let second = MotivationMessageGenerator.message(for: .dailyEncouragement, seed: seed)
    #expect(first == second)
    #expect(!first.body.isEmpty)
  }

  @Test func taskDeadlineIncludesTitle() {
    let message = MotivationMessageGenerator.message(for: .taskDeadline(title: "Write spec"))
    #expect(message.title.contains("Write spec"))
  }

  @Test func streakMessageReferencesDays() {
    let message = MotivationMessageGenerator.message(for: .streak(days: 5))
    #expect(message.title.contains("5"))
  }
}
