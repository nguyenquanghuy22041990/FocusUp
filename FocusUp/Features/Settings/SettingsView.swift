//
//  SettingsView.swift
//  FocusUp
//

import SwiftUI

struct SettingsView: View {
  @Environment(\.appContainer) private var container
  @State private var notificationSettingsViewModel: NotificationSettingsViewModel?

  var body: some View {
    @Bindable var tabCoordinator = container.coordinator.tabCoordinators.settings

    FeatureNavigationShell(coordinator: tabCoordinator) {
      SettingsHomeView()
    } destination: { route in
      destination(for: route)
    }
    .task {
      ensureNotificationSettingsViewModel()
    }
  }

  @ViewBuilder
  private func destination(for route: SettingsRoute) -> some View {
    switch route {
    case .notifications:
      if let notificationSettingsViewModel {
        NotificationSettingsView(viewModel: notificationSettingsViewModel)
      } else {
        NotificationSettingsHostView()
      }
    case .appearance:
      AppearanceSettingsView()
    case .about:
      AboutView()
    }
  }

  private func ensureNotificationSettingsViewModel() {
    guard notificationSettingsViewModel == nil else { return }
    notificationSettingsViewModel = NotificationSettingsViewModel(
      notificationService: container.notificationService,
      preferencesRepository: container.userPreferencesRepository,
      notificationScheduler: container.notificationScheduler
    )
  }
}

#Preview {
  SettingsView()
    .appContainer(.preview)
}
