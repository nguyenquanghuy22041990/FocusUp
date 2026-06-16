//
//  RestTimerView.swift
//  FocusUp
//

import SwiftUI

struct RestTimerView: View {
  @Bindable var viewModel: RestTimerViewModel
  var onSessionEnded: () -> Void

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.focusMotionReduced) private var motionReduced
  @Environment(\.hapticFeedback) private var hapticFeedback
  @Environment(\.scenePhase) private var scenePhase

  var body: some View {
    ResponsiveContainer(wide: horizontalSizeClass == .regular) {
      VStack(spacing: AppSpacingScale.scaled(AppSpacing.xl, horizontalSizeClass: horizontalSizeClass, dynamicTypeSize: dynamicTypeSize)) {
        header
          .calmStateTransition(id: viewModel.animationPhase)

        if viewModel.showCompletionBanner {
          completionBanner
            .calmStateTransition(id: "completed")
        }

        if viewModel.hasActiveSession {
          activeTimerSection
        } else {
          setupSection
        }

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
    .navigationTitle("Rest")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBackLocked(viewModel.locksBackNavigation)
    .hidesTabBarForActiveTimer()
    .task(id: viewModel.hasActiveSession) {
      await runTimerLoop()
    }
  }

  private var header: some View {
    VStack(spacing: AppSpacing.sm) {
      Image(systemName: "leaf.fill")
        .font(.system(size: 40))
        .foregroundStyle(AppColors.rest)
        .calmBreathing()
        .accessibilityHidden(true)

      Text("Take a calm break")
        .appFont(.title)
        .multilineTextAlignment(.center)

      Text("Slow down, breathe, and let your mind recover.")
        .appFont(.callout)
        .foregroundStyle(AppColors.secondaryText)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
  }

  private var setupSection: some View {
    VStack(spacing: AppSpacing.lg) {
      RestDurationPresetPicker(selection: $viewModel.selectedPreset)
      PrimaryButton(
        title: "Begin Rest",
        isLoading: viewModel.isStarting,
        isDisabled: !viewModel.canStart
      ) {
        _Concurrency.Task {
          _ = await viewModel.startSession()
        }
      }
      .accessibilityHint("Starts a rest session with the selected duration")
    }
    .calmStateTransition(id: "setup")
  }

  @ViewBuilder
  private var activeTimerSection: some View {
    VStack(spacing: AppSpacing.lg) {
      timerContent
      RestTimerControlsView(
        interactionState: viewModel.interactionState,
        isPerformingAction: viewModel.interactionState == .performingAction,
        onPause: { _Concurrency.Task { await viewModel.pause() } },
        onResume: { _Concurrency.Task { await viewModel.resume() } },
        onComplete: { performComplete() },
        onCancel: { performCancel() }
      )
    }
    .calmStateTransition(id: viewModel.animationPhase)
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
    RestTimerDisplayView(
      progress: viewModel.progress(at: date),
      remainingLabel: viewModel.remainingLabel(at: date),
      statusLabel: viewModel.statusAccessibilityLabel,
      sessionTitle: viewModel.sessionTitle,
      remainingAccessibility: viewModel.remainingAccessibilityDescription(at: date)
    )
  }

  private var completionBanner: some View {
    AppCard {
      VStack(alignment: .leading, spacing: AppSpacing.xs) {
        Text("Rest complete")
          .appFont(.headline)
        Text("You're refreshed. Return when you feel ready.")
          .appFont(.callout)
          .foregroundStyle(AppColors.secondaryText)
      }
    }
    .focusStateTransition(id: viewModel.showCompletionBanner)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Rest complete. You're refreshed.")
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
