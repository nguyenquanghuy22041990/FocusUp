//
//  FocusTimerControlsView.swift
//  FocusUp
//

import SwiftUI

struct FocusTimerControlsView: View {
  let interactionState: FocusTimerInteractionState
  let isPerformingAction: Bool
  let onPause: () -> Void
  let onResume: () -> Void
  let onComplete: () -> Void
  let onCancel: () -> Void

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    VStack(spacing: AppSpacing.md) {
      controlButtons
      DestructiveButton(title: "End Session", isDisabled: isPerformingAction, action: onCancel)
        .accessibilityHint("Cancels the current focus session")
    }
    .accessibilityElement(children: .contain)
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
        .accessibilityHint("Pauses the focus timer")

      case .paused:
        PrimaryButton(
          title: "Resume",
          isLoading: isPerformingAction,
          isDisabled: isPerformingAction,
          action: onResume
        )
        .accessibilityHint("Resumes the focus timer")

      case .completed, .idle:
        EmptyView()
      }
    }

    if interactionState == .running || interactionState == .paused {
      PrimaryButton(
        title: "Complete",
        isLoading: isPerformingAction,
        isDisabled: isPerformingAction,
        action: onComplete
      )
      .accessibilityHint("Marks the focus session as complete")
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
