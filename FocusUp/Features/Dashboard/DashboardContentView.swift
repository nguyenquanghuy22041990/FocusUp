//
//  DashboardContentView.swift
//  FocusUp
//

import SwiftUI

struct DashboardContentView: View {
  @Bindable var viewModel: DashboardViewModel
  let coordinator: AppCoordinator

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.focusMotionReduced) private var motionReduced

  var body: some View {
    VStack(alignment: .leading, spacing: AdaptiveSpacing.sectionSpacing(horizontalSizeClass: horizontalSizeClass)) {
      DashboardStateHeader(snapshot: viewModel.snapshot)

      if viewModel.hasActiveSession {
        DashboardActiveSessionCard(
          viewModel: viewModel,
          onContinue: { viewModel.openFocusSession(using: coordinator) },
          onPause: { _Concurrency.Task { await viewModel.pauseSession() } },
          onResume: { _Concurrency.Task { await viewModel.resumeSession() } }
        )
      } else if viewModel.snapshot.continuity.hasActiveRest {
        restContinuationCard
      }

      if let error = viewModel.sessionActionError {
        Text(error)
          .appFont(.callout)
          .foregroundStyle(AppColors.error)
          .accessibilityLabel("Error: \(error)")
      }

      DashboardMetricsSection(statistics: viewModel.snapshot.statistics)

      DashboardPrioritySection(priorities: viewModel.snapshot.priorities) { taskID in
        viewModel.openTask(taskID, using: coordinator)
      }

      DashboardMotivationSection(
        title: viewModel.snapshot.motivationalTitle,
        bodyText: viewModel.snapshot.motivationalBody
      )
    }
    .focusMotionAnimation(viewModel.snapshot.mood, style: .softFade)
  }

  private var restContinuationCard: some View {
    AppCard {
      VStack(alignment: .leading, spacing: AppSpacing.sm) {
        Label("Rest in progress", systemImage: "leaf.fill")
          .appFont(.headline)
          .foregroundStyle(AppColors.rest)
        Text("Your rest session continues on the Rest screen.")
          .appFont(.callout)
          .foregroundStyle(AppColors.secondaryText)
          .appMultilineText()
        SecondaryButton(title: "Return to rest", action: { viewModel.openRestSession(using: coordinator) })
      }
    }
    .accessibilityElement(children: .combine)
  }
}
