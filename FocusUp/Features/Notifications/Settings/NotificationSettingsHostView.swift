//
//  NotificationSettingsHostView.swift
//  FocusUp
//

import SwiftUI

/// Creates a stable settings view model when this destination appears (fixes pre-warmed VM race).
struct NotificationSettingsHostView: View {
  @Environment(\.appContainer) private var container
  @State private var viewModel: NotificationSettingsViewModel?

  var body: some View {
    Group {
      if let viewModel {
        NotificationSettingsView(viewModel: viewModel)
      } else {
        ProgressView()
          .frame(maxWidth: .infinity, minHeight: 200)
      }
    }
    .task {
      ensureViewModel()
    }
    .onAppear(perform: ensureViewModel)
  }

  private func ensureViewModel() {
    guard viewModel == nil else { return }
    viewModel = NotificationSettingsViewModel(
      notificationService: container.notificationService,
      preferencesRepository: container.userPreferencesRepository,
      notificationScheduler: container.notificationScheduler
    )
  }
}
