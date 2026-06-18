//
//  FocusTimerView.swift
//  FocusUp
//

import SwiftUI

struct FocusTimerView: View {
  @Bindable var viewModel: FocusTimerViewModel
  var onSessionEnded: () -> Void
  var onStartRest: (() -> Void)?

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.focusMotionReduced) private var motionReduced
  @Environment(\.hapticFeedback) private var hapticFeedback
  @Environment(\.scenePhase) private var scenePhase

  var body: some View {
    ResponsiveContainer(wide: horizontalSizeClass == .regular) {
      VStack(spacing: AppSpacingScale.scaled(AppSpacing.xl, horizontalSizeClass: horizontalSizeClass, dynamicTypeSize: dynamicTypeSize)) {
        if viewModel.showCompletionBanner {
          completionBanner
        }

        timerContent
          .focusStateTransition(id: viewModel.interactionState)

        FocusTimerControlsView(
          interactionState: viewModel.interactionState,
          isPerformingAction: viewModel.interactionState == .performingAction,
          onPause: { performPause() },
          onResume: { performResume() },
          onComplete: { performComplete() },
          onCancel: { performCancel() }
        )

        if let error = viewModel.errorMessage {
          Text(error)
            .appFont(.callout)
            .foregroundStyle(AppColors.error)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel("Error: \(error)")
        }
      }
      .padding(.vertical, AppSpacing.lg)
    }
    .navigationTitle("Focus")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBackLocked(viewModel.locksBackNavigation)
    .hidesTabBarForActiveTimer()
    .task(id: viewModel.hasActiveSession) {
      await viewModel.loadAssociatedTask()
      await runTimerLoop()
    }
  }

  @ViewBuilder
  private var timerContent: some View {
    if motionReduced {
      timerDisplay(at: .now)
    } else {
      TimelineView(.periodic(from: .now, by: 1)) { context in
        timerDisplay(at: context.date)
      }
    }
  }

  private func timerDisplay(at date: Date) -> some View {
    FocusTimerDisplayView(
      progress: viewModel.progress(at: date),
      remainingLabel: viewModel.remainingLabel(at: date),
      statusLabel: viewModel.statusAccessibilityLabel,
      sessionTitle: viewModel.sessionTitle,
      taskTitle: viewModel.associatedTask?.title,
      elapsedAccessibility: viewModel.elapsedAccessibilityDescription(at: date),
      remainingAccessibility: viewModel.remainingAccessibilityDescription(at: date)
    )
  }

  private var completionBanner: some View {
    AppCard {
      VStack(alignment: .leading, spacing: AppSpacing.sm) {
        Text("Session complete")
          .appFont(.headline)
        Text("Great work. Take a short break before your next session.")
          .appFont(.callout)
          .foregroundStyle(AppColors.secondaryText)

        if let onStartRest {
          SecondaryButton(title: "Take a Rest Break", action: onStartRest)
            .accessibilityHint("Opens the rest timer")
        }
      }
    }
    .focusStateTransition(id: viewModel.showCompletionBanner)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Session complete. Great work.")
  }

  private func runTimerLoop() async {
    guard viewModel.hasActiveSession else { return }

    while !_Concurrency.Task.isCancelled, viewModel.hasActiveSession {
      if scenePhase == .active {
        await viewModel.advanceTimerTick()
      }
      try? await _Concurrency.Task.sleep(for: .seconds(1))
    }
  }

  private func performPause() {
    _Concurrency.Task { await viewModel.pause() }
  }

  private func performResume() {
    _Concurrency.Task { await viewModel.resume() }
  }

  private func performComplete() {
    _Concurrency.Task {
      if await viewModel.complete() {
        hapticFeedback.sessionCompleted()
        onSessionEnded()
      }
    }
  }

  private func performCancel() {
    _Concurrency.Task {
      if await viewModel.cancel() {
        onSessionEnded()
      }
    }
  }
}
