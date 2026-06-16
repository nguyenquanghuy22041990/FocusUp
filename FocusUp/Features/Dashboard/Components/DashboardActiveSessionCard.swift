//
//  DashboardActiveSessionCard.swift
//  FocusUp
//

import SwiftUI

struct DashboardActiveSessionCard: View {
  @Bindable var viewModel: DashboardViewModel
  let onContinue: () -> Void
  let onPause: () -> Void
  let onResume: () -> Void

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.focusMotionReduced) private var motionReduced

  var body: some View {
    Group {
      if motionReduced {
        cardContent(at: .now)
      } else {
        TimelineView(.periodic(from: .now, by: 1)) { context in
          cardContent(at: context.date)
        }
      }
    }
  }

  @ViewBuilder
  private func cardContent(at date: Date) -> some View {
    if let session = viewModel.activeSession(at: date) {
      AppCard {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
          Label("Focus in progress", systemImage: "brain.head.profile")
            .appFont(.headline)
            .foregroundStyle(AppColors.focus)

          TimerRingView(
            progress: session.progress,
            remainingLabel: session.remainingLabel,
            caption: session.isPaused ? "Paused" : "Remaining",
            tint: AppColors.focus
          )
          .frame(maxWidth: horizontalSizeClass == .regular ? 220 : .infinity)
          .frame(maxWidth: .infinity)
          .focusNumericTransition(value: session.remainingSeconds)

          VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(session.title)
              .appFont(.title)
              .foregroundStyle(AppColors.primaryText)
            if let taskTitle = session.taskTitle {
              Text("Task: \(taskTitle)")
                .appFont(.callout)
                .foregroundStyle(AppColors.secondaryText)
            }
          }

          AdaptiveContent {
            HStack(spacing: AppSpacing.sm) {
              sessionControls(isPaused: session.isPaused)
              PrimaryButton(title: "Continue session", action: onContinue)
            }
          } fallback: {
            VStack(spacing: AppSpacing.sm) {
              sessionControls(isPaused: session.isPaused)
              PrimaryButton(title: "Continue session", action: onContinue)
            }
          }
        }
      }
      .accessibilityElement(children: .contain)
      .accessibilityLabel(session.accessibilitySummary)
      .focusStateTransition(id: session.sessionID)
    }
  }

  @ViewBuilder
  private func sessionControls(isPaused: Bool) -> some View {
    if isPaused {
      SecondaryButton(
        title: "Resume",
        isLoading: viewModel.isPerformingSessionAction,
        isDisabled: viewModel.isPerformingSessionAction,
        action: onResume
      )
      .accessibilityHint("Resumes the focus session")
    } else {
      SecondaryButton(
        title: "Pause",
        isLoading: viewModel.isPerformingSessionAction,
        isDisabled: viewModel.isPerformingSessionAction,
        action: onPause
      )
      .accessibilityHint("Pauses the focus session")
    }
  }
}
