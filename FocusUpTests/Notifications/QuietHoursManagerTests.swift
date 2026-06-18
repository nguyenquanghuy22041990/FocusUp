//
//  QuietHoursManagerTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@Suite(.tags(.notifications))
struct QuietHoursManagerTests {
  private var calendar: Calendar {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(secondsFromGMT: 0)!
    return cal
  }

  @Test func overnightQuietHoursDetectsLateNight() {
    let quiet = QuietHoursConfiguration(isEnabled: true, startHour: 22, endHour: 7)
    var components = DateComponents()
    components.year = 2026
    components.month = 5
    components.day = 21
    components.hour = 23
    let date = calendar.date(from: components)!
    #expect(quiet.contains(date: date, calendar: calendar))
  }

  @Test func overnightQuietHoursAllowsMidday() {
    let quiet = QuietHoursConfiguration(isEnabled: true, startHour: 22, endHour: 7)
    var components = DateComponents()
    components.year = 2026
    components.month = 5
    components.day = 21
    components.hour = 14
    let date = calendar.date(from: components)!
    #expect(!quiet.contains(date: date, calendar: calendar))
  }

  @Test func adjustedDeliveryMovesOutOfQuietHours() {
    let quiet = QuietHoursConfiguration(isEnabled: true, startHour: 22, endHour: 7)
    var components = DateComponents()
    components.year = 2026
    components.month = 5
    components.day = 21
    components.hour = 23
    let proposed = calendar.date(from: components)!
    let adjusted = QuietHoursManager.adjustedDeliveryDate(
      for: proposed,
      quietHours: quiet,
      calendar: calendar
    )
    #expect(!quiet.contains(date: adjusted, calendar: calendar))
    #expect(adjusted > proposed)
  }

  @Test func disabledQuietHoursPassesThrough() {
    let quiet = QuietHoursConfiguration(isEnabled: false)
    let date = Date(timeIntervalSince1970: 0)
    #expect(QuietHoursManager.adjustedDeliveryDate(for: date, quietHours: quiet) == date)
  }
}
