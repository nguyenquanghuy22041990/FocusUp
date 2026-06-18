//
//  FocusTransitionModifiers.swift
//  FocusUp
//

import SwiftUI

// MARK: - Value-driven animation

private struct FocusMotionAnimationModifier<Value: Equatable>: ViewModifier {
  let value: Value
  let style: FocusMotion.Style
  @Environment(\.focusMotionReduced) private var motionReduced

  func body(content: Content) -> some View {
    content.animation(FocusMotion.animation(reduced: motionReduced, style: style), value: value)
  }
}

// MARK: - State / content transitions

private struct FocusStateTransitionModifier<ID: Hashable>: ViewModifier {
  let id: ID
  @Environment(\.focusMotionReduced) private var motionReduced

  func body(content: Content) -> some View {
    content
      .contentTransition(.opacity)
      .animation(FocusMotion.animation(reduced: motionReduced, style: .gentleSpring), value: id)
  }
}

private struct FocusCardAppearanceModifier: ViewModifier {
  @Environment(\.focusMotionReduced) private var motionReduced
  @State private var isVisible = false

  func body(content: Content) -> some View {
    content
      .opacity(motionReduced ? 1 : (isVisible ? 1 : 0.94))
      .animation(FocusMotion.animation(reduced: motionReduced, style: .cardAppear), value: isVisible)
      .onAppear {
        guard !motionReduced else { return }
        isVisible = true
      }
  }
}

private struct FocusValidationMessageModifier: ViewModifier {
  let message: String?
  @Environment(\.focusMotionReduced) private var motionReduced

  func body(content: Content) -> some View {
    content
      .opacity(message == nil ? 0 : 1)
      .animation(FocusMotion.animation(reduced: motionReduced, style: .softFade), value: message)
  }
}

// MARK: - Public API

extension View {
  func focusMotionAnimation<Value: Equatable>(
    _ value: Value,
    style: FocusMotion.Style = .softFade
  ) -> some View {
    modifier(FocusMotionAnimationModifier(value: value, style: style))
  }

  func focusStateTransition<ID: Hashable>(id: ID) -> some View {
    modifier(FocusStateTransitionModifier(id: id))
  }

  func focusCardAppearance() -> some View {
    modifier(FocusCardAppearanceModifier())
  }

  func focusValidationTransition(message: String?) -> some View {
    modifier(FocusValidationMessageModifier(message: message))
  }

  /// Applies numeric text transitions to timer and metric labels.
  func focusNumericTransition<Value: Equatable>(value: Value) -> some View {
    modifier(FocusNumericTransitionModifier(value: value))
  }
}

private struct FocusNumericTransitionModifier<Value: Equatable>: ViewModifier {
  let value: Value
  @Environment(\.focusMotionReduced) private var motionReduced

  func body(content: Content) -> some View {
    content
      .contentTransition(motionReduced ? .identity : .numericText())
      .animation(FocusMotion.animation(reduced: motionReduced, style: .progress), value: value)
  }
}
