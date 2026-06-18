//
//  QuietHoursManager.swift
//  FocusUp
//

import Foundation

enum QuietHoursManager {
  /// Returns whether delivery should be suppressed at the given time.
  static func shouldSuppress(
    at date: Date,
    quietHours: QuietHoursConfiguration
  ) -> Bool {
    quietHours.contains(date: date)
  }

  /// Moves a proposed delivery date out of quiet hours (to the next quiet-period end).
  static func adjustedDeliveryDate(
    for proposed: Date,
    quietHours: QuietHoursConfiguration,
    calendar: Calendar = .current
  ) -> Date {
    guard quietHours.isEnabled, quietHours.contains(date: proposed, calendar: calendar) else {
      return proposed
    }
    return quietPeriodEnd(after: proposed, quietHours: quietHours, calendar: calendar)
  }

  static func quietPeriodEnd(
    after date: Date,
    quietHours: QuietHoursConfiguration,
    calendar: Calendar = .current
  ) -> Date {
    var components = calendar.dateComponents([.year, .month, .day], from: date)
    components.hour = quietHours.endHour
    components.minute = quietHours.endMinute
    components.second = 0

    guard var end = calendar.date(from: components) else { return date }

    let dateMinutes = (calendar.component(.hour, from: date) * 60)
      + calendar.component(.minute, from: date)
    let startMinutes = quietHours.startHour * 60 + quietHours.startMinute
    let endMinutes = quietHours.endHour * 60 + quietHours.endMinute

    if quietHours.spansMidnight, dateMinutes >= startMinutes {
      end = calendar.date(byAdding: .day, value: 1, to: end) ?? end
    } else if end <= date {
      end = calendar.date(byAdding: .day, value: 1, to: end) ?? end
    }

    if end <= date {
      end = date.addingTimeInterval(60)
    }

    return end
  }
}
