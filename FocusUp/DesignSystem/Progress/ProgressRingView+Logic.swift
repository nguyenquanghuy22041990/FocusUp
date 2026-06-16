//
//  ProgressRingView+Logic.swift
//  FocusUp
//

import Foundation

enum ProgressRingLogic {
  static func clampedProgress(_ progress: Double) -> Double {
    min(max(progress, 0), 1)
  }
}
