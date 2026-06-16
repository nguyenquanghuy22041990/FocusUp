//
//  NotificationPermissionViewModel.swift
//  FocusUp
//

import Foundation
import Observation

enum NotificationPermissionStep: Equatable, Sendable {
  case education
  case denied
  case authorized
  case loading
}

@MainActor
@Observable
final class NotificationPermissionViewModel {
  private let notificationService: any NotificationService
  private let preferencesRepository: any UserPreferencesRepository

  private(set) var step: NotificationPermissionStep = .loading
  var errorMessage: String?

  var onCompleted: (() -> Void)?

  init(
    notificationService: any NotificationService,
    preferencesRepository: any UserPreferencesRepository
  ) {
    self.notificationService = notificationService
    self.preferencesRepository = preferencesRepository
  }

  func load() async {
    step = .loading
    let status = await notificationService.authorizationStatus()

    if status.canScheduleNotifications {
      step = .authorized
      return
    }
    if status.needsSettingsRecovery {
      step = .denied
      return
    }
    step = .education
  }

  func requestPermission() async {
    step = .loading
    errorMessage = nil

    var preferences = (try? await preferencesRepository.fetch()) ?? UserPreferences()
    preferences.notifications.hasSeenPermissionEducation = true
    try? await preferencesRepository.save(preferences)

    let status = await notificationService.requestAuthorization()
    switch status {
    case .authorized, .provisional, .ephemeral:
      step = .authorized
      onCompleted?()
    case .denied:
      step = .denied
    case .notDetermined:
      step = .education
    }
  }

  func openSettings() {
    notificationService.openSystemSettings()
  }

  func continueWithoutNotifications() async {
    var preferences = (try? await preferencesRepository.fetch()) ?? UserPreferences()
    preferences.notifications.hasSeenPermissionEducation = true
    try? await preferencesRepository.save(preferences)
    onCompleted?()
  }
}
