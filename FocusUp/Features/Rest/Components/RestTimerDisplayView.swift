//
//  RestTimerDisplayView.swift
//  FocusUp
//

import SwiftUI

struct RestTimerDisplayView: View {
  let progress: Double
  let remainingLabel: String
  let statusLabel: String
  let sessionTitle: String
  let remainingAccessibility: String

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @ScaledMetric(relativeTo: .largeTitle) private var ringScale: CGFloat = 1

  var body: some View {
    VStack(spacing: AppSpacing.lg) {
      TimerRingView(
        progress: progress,
        remainingLabel: remainingLabel,
        caption: statusLabel,
        tint: AppColors.rest
      )
      .calmBreathing(intensity: horizontalSizeClass == .regular ? 0.015 : 0.02)
      .scaleEffect(ringScale)
      .accessibilityElement(children: .ignore)
      .accessibilityLabel("Rest timer")
      .accessibilityValue("\(statusLabel). \(remainingAccessibility)")

      Text(sessionTitle)
        .appFont(.title)
        .multilineTextAlignment(.center)
        .foregroundStyle(AppColors.primaryText)
        .focusNumericTransition(value: remainingLabel)
        .padding(.top, AppSpacing.sm)
    }
    .frame(maxWidth: .infinity)
  }
}
