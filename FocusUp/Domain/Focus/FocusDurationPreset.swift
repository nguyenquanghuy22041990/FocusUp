//
//  FocusDurationPreset.swift
//  FocusUp
//

import Foundation

enum FocusDurationPreset: Int, CaseIterable, Identifiable, Sendable {
  case fifteen = 15
  case thirty = 30
  case sixty = 60

  var id: Int { rawValue }

  var label: String {
    "\(rawValue) min"
  }

  var durationSeconds: Int {
    rawValue * 60
  }

  var accessibilityLabel: String {
    "\(rawValue) minutes"
  }
}
