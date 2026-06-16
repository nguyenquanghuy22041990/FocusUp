//
//  Activity+Extensions.swift
//  FocusUp
//

import Foundation

#if canImport(ActivityKit)
import ActivityKit

extension FocusSessionAttributes {
  var plannedEndDate: Date {
    startDate.addingTimeInterval(TimeInterval(totalDurationSeconds))
  }
}
#endif
