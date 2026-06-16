//
//  FocusTimerStartView.swift
//  FocusUp
//

import SwiftUI

struct FocusTimerStartView: View {
  @Bindable var viewModel: FocusTimerStartViewModel
  var onSessionStarted: () -> Void
  var onRestTapped: (() -> Void)?

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    ResponsiveContainer {
      VStack(spacing: AppSpacingScale.scaled(AppSpacing.xl, horizontalSizeClass: horizontalSizeClass, dynamicTypeSize: dynamicTypeSize)) {
        header
        FocusDurationPresetPicker(selection: $viewModel.selectedPreset)
        FocusTaskAssociationPicker(tasks: viewModel.availableTasks, selectedTask: $viewModel.selectedTask)
          .onChange(of: viewModel.selectedTask?.id) { _, _ in
            viewModel.syncCustomTitleFromSelectedTask()
          }
        customTitleField
        if viewModel.hasActiveSessionElsewhere {
          activeSessionNotice
        }
        startButton
        restLink
        if case .error(let message) = viewModel.state {
          errorBanner(message)
        }
      }
      .padding(.vertical, AppSpacing.lg)
    }
    .navigationTitle("Focus")
    .navigationBarTitleDisplayMode(.large)
    .onAppear {
      _Concurrency.Task { await viewModel.loadTasks() }
    }
    .onReceive(NotificationCenter.default.publisher(for: TaskUpdateNotifier.name)) { _ in
      _Concurrency.Task { await viewModel.loadTasks() }
    }
    .task {
      await viewModel.loadTasks()
    }
  }

  private var header: some View {
    VStack(spacing: AppSpacing.sm) {
      Image(systemName: "brain.head.profile")
        .font(.system(size: 44))
        .foregroundStyle(AppColors.focus)
        .focusCardAppearance()
        .accessibilityHidden(true)

      Text("Prepare your focus")
        .appFont(.title)
        .multilineTextAlignment(.center)
        .foregroundStyle(AppColors.primaryText)

      Text("Choose a duration and optionally link a task.")
        .appFont(.callout)
        .multilineTextAlignment(.center)
        .foregroundStyle(AppColors.secondaryText)
    }
    .frame(maxWidth: .infinity)
  }

  private var customTitleField: some View {
    VStack(alignment: .leading, spacing: AppSpacing.xs) {
      Text("Session name")
        .appFont(.headline)
        .foregroundStyle(AppColors.primaryText)

      TextField("Focus Session", text: $viewModel.customTitle)
        .textFieldStyle(.roundedBorder)
        .accessibilityLabel("Session name")
        .accessibilityHint(
          viewModel.selectedTask == nil
            ? "Custom session title"
            : "Session title; prefilled from linked task and editable"
        )
    }
  }

  private var activeSessionNotice: some View {
    Text("A focus session is already in progress.")
      .appFont(.callout)
      .foregroundStyle(AppColors.secondaryText)
      .frame(maxWidth: .infinity, alignment: .leading)
      .accessibilityLabel("A focus session is already in progress")
  }

  @ViewBuilder
  private var restLink: some View {
    if let onRestTapped {
      SecondaryButton(title: "Take a Rest Break", action: onRestTapped)
        .accessibilityHint("Opens the rest timer screen")
    }
  }

  private var startButton: some View {
    PrimaryButton(
      title: "Start Focus",
      isLoading: viewModel.state == .starting,
      isDisabled: !viewModel.canStart
    ) {
      _Concurrency.Task {
        if await viewModel.startSession() {
          onSessionStarted()
        }
      }
    }
    .accessibilityHint("Starts a focus session with the selected duration")
  }

  private func errorBanner(_ message: String) -> some View {
    Text(message)
      .appFont(.callout)
      .foregroundStyle(AppColors.error)
      .frame(maxWidth: .infinity, alignment: .leading)
      .accessibilityLabel("Error: \(message)")
  }
}
