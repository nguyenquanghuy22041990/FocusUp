//
//  QuietHoursConfiguration.swift
//  FocusUp
//

import Foundation

struct QuietHoursConfiguration: Equatable, Codable, Sendable {
  var isEnabled: Bool
  var startHour: Int
  var startMinute: Int
  var endHour: Int
  var endMinute: Int

  init(
    isEnabled: Bool = true,
    startHour: Int = 22,
    startMinute: Int = 0,
    endHour: Int = 7,
    endMinute: Int = 0
  ) {
    self.isEnabled = isEnabled
    self.startHour = min(23, max(0, startHour))
    self.startMinute = min(59, max(0, startMinute))
    self.endHour = min(23, max(0, endHour))
    self.endMinute = min(59, max(0, endMinute))
  }

  static let `default` = QuietHoursConfiguration()

  private var startTotalMinutes: Int { startHour * 60 + startMinute }
  private var endTotalMinutes: Int { endHour * 60 + endMinute }

  var spansMidnight: Bool {
    startTotalMinutes > endTotalMinutes
  }

  func contains(date: Date, calendar: Calendar = .current) -> Bool {
    guard isEnabled else { return false }
    let components = calendar.dateComponents([.hour, .minute], from: date)
    let minutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)

    if spansMidnight {
      return minutes >= startTotalMinutes || minutes < endTotalMinutes
    }
    return minutes >= startTotalMinutes && minutes < endTotalMinutes
  }
}
