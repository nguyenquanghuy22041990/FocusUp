//
//  NotificationPermissionView.swift
//  FocusUp
//

import SwiftUI

struct NotificationPermissionView: View {
  @Bindable var viewModel: NotificationPermissionViewModel

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  var body: some View {
    ReadableContentView {
      VStack(alignment: .leading, spacing: AdaptiveSpacing.sectionSpacing(horizontalSizeClass: horizontalSizeClass)) {
        switch viewModel.step {
        case .loading:
          ProgressView()
            .frame(maxWidth: .infinity, minHeight: 200)
        case .education:
          educationContent
        case .denied:
          deniedContent
        case .authorized:
          authorizedContent
        }
      }
      .adaptiveScreenPadding()
    }
    .navigationTitle("Notifications")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      await viewModel.load()
    }
  }

  private var educationContent: some View {
    VStack(alignment: .leading, spacing: AppSpacing.lg) {
      AppTextStyles.screenTitle("Stay gently informed")
      AppTextStyles.screenSubtitle(
        "Optional reminders for focus sessions, task deadlines, and calm encouragement. You're always in control."
      )

      VStack(alignment: .leading, spacing: AppSpacing.sm) {
        benefitRow(icon: "timer", text: "Session completion acknowledgements")
        benefitRow(icon: "calendar", text: "Respectful deadline reminders")
        benefitRow(icon: "moon.fill", text: "Quiet hours to protect your rest")
      }

      if let errorMessage = viewModel.errorMessage {
        Text(errorMessage)
          .appFont(.caption)
          .foregroundStyle(AppColors.error)
      }

      PrimaryButton(title: "Enable notifications") {
        _Concurrency.Task { await viewModel.requestPermission() }
      }

      SecondaryButton(title: "Not now") {
        _Concurrency.Task { await viewModel.continueWithoutNotifications() }
      }
    }
    .accessibilityElement(children: .contain)
  }

  private var deniedContent: some View {
    VStack(alignment: .leading, spacing: AppSpacing.lg) {
      AppTextStyles.screenTitle("Notifications are off")
      AppTextStyles.screenSubtitle(
        "You can enable reminders anytime in Settings. We'll never prompt repeatedly."
      )

      SecondaryButton(title: "Open Settings") {
        viewModel.openSettings()
      }

      Button("Continue without notifications") {
        _Concurrency.Task { await viewModel.continueWithoutNotifications() }
      }
      .font(AppTypography.body())
      .foregroundStyle(AppColors.secondaryText)
      .frame(minHeight: AppSpacing.minimumTouchTarget)
    }
  }

  private var authorizedContent: some View {
    VStack(alignment: .leading, spacing: AppSpacing.md) {
      Label("Notifications enabled", systemImage: "checkmark.circle.fill")
        .appFont(.headline)
        .foregroundStyle(AppColors.success)
      AppTextStyles.screenSubtitle("Adjust reminder types and quiet hours below.")
    }
  }

  private func benefitRow(icon: String, text: String) -> some View {
    Label(text, systemImage: icon)
      .appFont(.body)
      .appMultilineText()
      .foregroundStyle(AppColors.secondaryText)
  }
}
