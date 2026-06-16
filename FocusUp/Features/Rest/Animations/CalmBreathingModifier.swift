//
//  CalmBreathingModifier.swift
//  FocusUp
//

import SwiftUI

/// Subtle breathing scale/opacity pulse for rest surfaces.
struct CalmBreathingModifier: ViewModifier {
  @Environment(\.focusMotionReduced) private var motionReduced
  @State private var isExpanded = false

  var intensity: CGFloat = FocusMotion.breathingIntensity

  func body(content: Content) -> some View {
    content
      .scaleEffect(motionReduced ? 1 : 1 + (isExpanded ? intensity : 0))
      .opacity(motionReduced ? 1 : (isExpanded ? 1 : 0.94))
      .animation(FocusMotion.animation(reduced: motionReduced, style: .breathing), value: isExpanded)
      .onAppear {
        guard !motionReduced else { return }
        isExpanded = true
      }
  }
}

extension View {
  func calmBreathing(intensity: CGFloat = 0.02) -> some View {
    modifier(CalmBreathingModifier(intensity: intensity))
  }
}
