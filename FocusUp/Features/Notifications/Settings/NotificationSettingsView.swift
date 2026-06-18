//
//  NotificationSettingsView.swift
//  FocusUp
//

import SwiftUI

struct NotificationSettingsView: View {
  @Bindable var viewModel: NotificationSettingsViewModel
  @State private var showPermissionFlow = false
  @State private var didFinishInitialLoad = false

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  var body: some View {
    ReadableContentView {
      VStack(alignment: .leading, spacing: AdaptiveSpacing.sectionSpacing(horizontalSizeClass: horizontalSizeClass)) {
        if viewModel.showsPermissionEducation {
          permissionBanner
        }

        if viewModel.showsDeniedRecovery {
          deniedBanner
        }

        reminderSection
        quietHoursSection

        if let errorMessage = viewModel.errorMessage {
          Text(errorMessage)
            .appFont(.caption)
            .foregroundStyle(AppColors.error)
        }
      }
      .adaptiveScreenPadding()
    }
    .navigationTitle("Notifications")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      await viewModel.load()
      didFinishInitialLoad = true
    }
    .onChange(of: viewModel.preferences) { _, _ in
      guard didFinishInitialLoad else { return }
      _Concurrency.Task { await viewModel.saveAndReschedule() }
    }
    .sheet(isPresented: $showPermissionFlow) {
      NavigationStack {
        permissionEducationSheet
      }
    }
  }

  private var permissionEducationSheet: some View {
    let permissionViewModel = viewModel.makePermissionViewModel()
    return NotificationPermissionView(viewModel: permissionViewModel)
      .onAppear {
        permissionViewModel.onCompleted = {
          showPermissionFlow = false
          _Concurrency.Task {
            await viewModel.refreshAuthorization()
            await viewModel.load()
            await viewModel.saveAndReschedule()
          }
        }
      }
  }

  private var permissionBanner: some View {
    AppCard {
      VStack(alignment: .leading, spacing: AppSpacing.sm) {
        Text("Enable when you're ready")
          .appFont(.headline)
        Text("We won't ask repeatedly. Tap below to learn what reminders include.")
          .appFont(.caption)
          .foregroundStyle(AppColors.secondaryText)
        SecondaryButton(title: "Learn about notifications") {
          showPermissionFlow = true
        }
      }
    }
  }

  private var deniedBanner: some View {
    AppCard {
      VStack(alignment: .leading, spacing: AppSpacing.sm) {
        Text("Notifications disabled in system settings")
          .appFont(.headline)
        SecondaryButton(title: "Open Settings", action: viewModel.openSystemSettings)
      }
    }
  }

  private var reminderSection: some View {
    VStack(alignment: .leading, spacing: AppSpacing.md) {
      sectionHeader(title: "Reminders", subtitle: "Choose what feels supportive")
      AppCard {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
          Toggle("Focus session completion", isOn: $viewModel.preferences.sessionCompletionRemindersEnabled)
          Toggle("Task deadline reminders", isOn: $viewModel.preferences.taskDeadlineRemindersEnabled)
          Toggle("Daily encouragement", isOn: $viewModel.preferences.motivationalRemindersEnabled)
          Toggle("Focus reminders", isOn: $viewModel.preferences.focusRemindersEnabled)
        }
      }
    }
    .accessibilityElement(children: .contain)
  }

  private var quietHoursSection: some View {
    VStack(alignment: .leading, spacing: AppSpacing.md) {
      sectionHeader(title: "Quiet hours", subtitle: "We'll defer notifications until morning")
      AppCard {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
          Toggle("Quiet hours enabled", isOn: $viewModel.preferences.quietHours.isEnabled)

          if viewModel.preferences.quietHours.isEnabled {
            quietHourPicker(
              label: "Start",
              hour: $viewModel.preferences.quietHours.startHour,
              minute: $viewModel.preferences.quietHours.startMinute
            )
            quietHourPicker(
              label: "End",
              hour: $viewModel.preferences.quietHours.endHour,
              minute: $viewModel.preferences.quietHours.endMinute
            )
          }
        }
      }
    }
    .accessibilityElement(children: .contain)
  }

  private func sectionHeader(title: String, subtitle: String?) -> some View {
    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
      Text(title)
        .appFont(.headline)
        .accessibilityAddTraits(.isHeader)
      if let subtitle {
        Text(subtitle)
          .appFont(.caption)
          .foregroundStyle(AppColors.secondaryText)
      }
    }
  }

  private func quietHourPicker(
    label: String,
    hour: Binding<Int>,
    minute: Binding<Int>
  ) -> some View {
    HStack {
      Text(label)
        .appFont(.body)
      Spacer()
      Picker("Hour", selection: hour) {
        ForEach(0..<24, id: \.self) { value in
          Text(String(format: "%02d", value)).tag(value)
        }
      }
      .pickerStyle(.menu)
      .accessibilityLabel("\(label) hour")

      Text(":")
        .foregroundStyle(AppColors.secondaryText)

      Picker("Minute", selection: minute) {
        ForEach([0, 15, 30, 45], id: \.self) { value in
          Text(String(format: "%02d", value)).tag(value)
        }
      }
      .pickerStyle(.menu)
      .accessibilityLabel("\(label) minute")
    }
    .frame(minHeight: AppSpacing.minimumTouchTarget)
  }
}
