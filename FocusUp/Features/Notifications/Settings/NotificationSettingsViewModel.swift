//
//  NotificationSettingsViewModel.swift
//  FocusUp
//

import Foundation
import Observation

@MainActor
@Observable
final class NotificationSettingsViewModel {
  private let notificationService: any NotificationService
  private let preferencesRepository: any UserPreferencesRepository
  private let notificationScheduler: any NotificationScheduling

  private(set) var authorization: NotificationAuthorizationState = .notDetermined
  var preferences: NotificationPreferences = .default
  private(set) var isSaving = false
  var errorMessage: String?

  var showsPermissionEducation: Bool {
    authorization.needsPermissionEducation && !preferences.hasSeenPermissionEducation
  }

  var showsDeniedRecovery: Bool {
    authorization.needsSettingsRecovery
  }

  init(
    notificationService: any NotificationService,
    preferencesRepository: any UserPreferencesRepository,
    notificationScheduler: any NotificationScheduling
  ) {
    self.notificationService = notificationService
    self.preferencesRepository = preferencesRepository
    self.notificationScheduler = notificationScheduler
  }

  func load() async {
    authorization = await notificationService.authorizationStatus()
    preferences = (try? await preferencesRepository.fetch())?.notifications ?? .default
  }

  func refreshAuthorization() async {
    authorization = await notificationService.authorizationStatus()
  }

  func saveAndReschedule() async {
    isSaving = true
    errorMessage = nil

    var stored = (try? await preferencesRepository.fetch()) ?? UserPreferences()
    stored.notifications = preferences
    stored.updatedAt = .now

    do {
      try await preferencesRepository.save(stored)
      if authorization.canScheduleNotifications {
        await notificationScheduler.rescheduleAll()
      }
    } catch {
      errorMessage = error.localizedDescription
    }

    isSaving = false
  }

  func openSystemSettings() {
    notificationService.openSystemSettings()
  }

  func markPermissionEducationSeen() async {
    preferences.hasSeenPermissionEducation = true
    await saveAndReschedule()
  }

  func makePermissionViewModel() -> NotificationPermissionViewModel {
    NotificationPermissionViewModel(
      notificationService: notificationService,
      preferencesRepository: preferencesRepository
    )
  }

  #if DEBUG
  func configureForPreview(
    authorization: NotificationAuthorizationState,
    preferences: NotificationPreferences
  ) {
    self.authorization = authorization
    self.preferences = preferences
  }
  #endif
}
