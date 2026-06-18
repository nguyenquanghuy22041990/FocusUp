//
//  RestTimerControlsView.swift
//  FocusUp
//

import SwiftUI

struct RestTimerControlsView: View {
  let interactionState: RestTimerInteractionState
  let isPerformingAction: Bool
  let onPause: () -> Void
  let onResume: () -> Void
  let onComplete: () -> Void
  let onCancel: () -> Void

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    VStack(spacing: AppSpacing.md) {
      controlButtons
      SecondaryButton(
        title: "End Rest",
        isDisabled: isPerformingAction,
        action: onCancel
      )
      .accessibilityHint("Ends the rest session early")
    }
  }

  @ViewBuilder
  private var controlButtons: some View {
    let layout = dynamicTypeSize.isAccessibilitySize
      ? AnyLayout(VStackLayout(spacing: AppSpacing.sm))
      : AnyLayout(HStackLayout(spacing: AppSpacing.sm))

    layout {
      switch interactionState {
      case .running, .performingAction:
        SecondaryButton(
          title: "Pause",
          isLoading: isPerformingAction,
          isDisabled: isPerformingAction,
          action: onPause
        )
        .accessibilityHint("Pauses the rest timer")

      case .paused:
        PrimaryButton(
          title: "Resume",
          isLoading: isPerformingAction,
          isDisabled: isPerformingAction,
          action: onResume
        )
        .accessibilityHint("Resumes the rest timer")

      case .completed, .idle, .setup:
        EmptyView()
      }
    }

    if interactionState == .running || interactionState == .paused {
      PrimaryButton(
        title: "Finish Rest",
        isLoading: isPerformingAction,
        isDisabled: isPerformingAction,
        action: onComplete
      )
      .accessibilityHint("Marks the rest session as complete")
    }
  }
}

private extension DynamicTypeSize {
  var isAccessibilitySize: Bool {
    switch self {
    case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
      true
    default:
      false
    }
  }
}
