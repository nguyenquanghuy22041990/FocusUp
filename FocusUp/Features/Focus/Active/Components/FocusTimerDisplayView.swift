//
//  FocusTimerDisplayView.swift
//  FocusUp
//

import SwiftUI

struct FocusTimerDisplayView: View {
  let progress: Double
  let remainingLabel: String
  let statusLabel: String
  let sessionTitle: String
  let taskTitle: String?
  let elapsedAccessibility: String
  let remainingAccessibility: String

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @ScaledMetric(relativeTo: .largeTitle) private var ringScale: CGFloat = 1

  private var ringLineWidth: CGFloat {
    horizontalSizeClass == .regular ? 14 : 12
  }

  var body: some View {
    VStack(spacing: AppSpacing.lg) {
      TimerRingView(
        progress: progress,
        remainingLabel: remainingLabel,
        caption: statusLabel,
        tint: AppColors.focus
      )
      .scaleEffect(ringScale)
      .accessibilityElement(children: .ignore)
      .accessibilityLabel("Focus timer")
      .accessibilityValue("\(statusLabel). \(remainingAccessibility). \(elapsedAccessibility)")

      VStack(spacing: AppSpacing.xs) {
        Text(sessionTitle)
          .appFont(.title)
          .multilineTextAlignment(.center)
          .foregroundStyle(AppColors.primaryText)

        if let taskTitle {
          Text("Task: \(taskTitle)")
            .appFont(.callout)
            .foregroundStyle(AppColors.secondaryText)
            .multilineTextAlignment(.center)
            .accessibilityLabel("Linked task \(taskTitle)")
        }
      }
      .padding(.top, AppSpacing.sm)
    }
    .frame(maxWidth: .infinity)
  }
}
