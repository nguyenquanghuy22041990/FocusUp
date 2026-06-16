//
//  ProgressRingView.swift
//  FocusUp
//

import SwiftUI

struct ProgressRingView: View {
  var progress: Double
  var lineWidth: CGFloat = 12
  var tint: Color = AppColors.focus
  var trackColor: Color = AppColors.surfaceElevated

  @Environment(\.focusMotionReduced) private var motionReduced
  @ScaledMetric(relativeTo: .title) private var ringSize: CGFloat = 120

  private var clampedProgress: Double {
    ProgressRingLogic.clampedProgress(progress)
  }

  var body: some View {
    ZStack {
      Circle()
        .stroke(trackColor, lineWidth: lineWidth)

      Circle()
        .trim(from: 0, to: clampedProgress)
        .stroke(
          tint,
          style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
        )
        .rotationEffect(.degrees(-90))
        .animation(FocusMotion.animation(reduced: motionReduced, style: .progress), value: clampedProgress)
    }
    .frame(width: ringSize, height: ringSize)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Progress")
    .accessibilityValue("\(Int(clampedProgress * 100)) percent")
  }
}
