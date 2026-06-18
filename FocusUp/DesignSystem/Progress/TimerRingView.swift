//
//  TimerRingView.swift
//  FocusUp
//

import SwiftUI

struct TimerRingView: View {
  var progress: Double
  var remainingLabel: String
  var caption: String = "Remaining"
  var tint: Color = AppColors.focus

  var body: some View {
    ZStack {
      ProgressRingView(progress: progress, tint: tint)

      VStack(spacing: AppSpacing.xxs) {
        Text(remainingLabel)
          .appFont(.title)
          .monospacedDigit()
          .focusNumericTransition(value: remainingLabel)
        Text(caption)
          .appFont(.caption)
          .foregroundStyle(AppColors.secondaryText)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(caption), \(remainingLabel)")
  }
}
