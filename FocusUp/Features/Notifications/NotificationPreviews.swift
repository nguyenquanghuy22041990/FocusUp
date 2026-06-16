//
//  NotificationPreviews.swift
//  FocusUp
//

import SwiftUI

#if DEBUG
enum NotificationPreviewSupport {
  static func settingsViewModel(
    authorization: NotificationAuthorizationState = .notDetermined,
    preferences: NotificationPreferences = .default
  ) -> NotificationSettingsViewModel {
    let persistence = PersistenceController.preview
    let vm = NotificationSettingsViewModel(
      notificationService: NoOpNotificationService(),
      preferencesRepository: UserPreferencesRepositoryImpl(context: persistence.mainContext),
      notificationScheduler: NotificationScheduler(
        notificationService: NoOpNotificationService(),
        preferencesRepository: UserPreferencesRepositoryImpl(context: persistence.mainContext),
        taskRepository: PreviewTaskRepository()
      )
    )
    vm.configureForPreview(authorization: authorization, preferences: preferences)
    return vm
  }
}

#Preview("Settings – Education") {
  NavigationStack {
    NotificationSettingsView(
      viewModel: NotificationPreviewSupport.settingsViewModel(authorization: .notDetermined)
    )
    .appContainer(.preview)
  }
}

#Preview("Settings – Denied") {
  NavigationStack {
    NotificationSettingsView(
      viewModel: NotificationPreviewSupport.settingsViewModel(authorization: .denied)
    )
    .appContainer(.preview)
  }
}

#Preview("Permission Education") {
  NavigationStack {
    NotificationPermissionView(
      viewModel: NotificationPermissionViewModel(
        notificationService: NoOpNotificationService(),
        preferencesRepository: UserPreferencesRepositoryImpl(
          context: PersistenceController.preview.mainContext
        )
      )
    )
    .appContainer(.preview)
  }
}

#Preview("Settings – Authorized") {
  NavigationStack {
    NotificationSettingsView(
      viewModel: NotificationPreviewSupport.settingsViewModel(authorization: .authorized)
    )
    .appContainer(.preview)
  }
}

#Preview("Settings – Dark") {
  NavigationStack {
    NotificationSettingsView(
      viewModel: NotificationPreviewSupport.settingsViewModel(authorization: .authorized)
    )
    .appContainer(.preview)
    .preferredColorScheme(.dark)
  }
}
#endif
