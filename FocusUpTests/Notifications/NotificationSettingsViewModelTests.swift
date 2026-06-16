//
//  NotificationSettingsViewModelTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

@MainActor
@Suite(.tags(.notifications))
struct NotificationSettingsViewModelTests {
  @Test
  func loadReadsPreferencesAndAuthorization() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let prefsRepo = UserPreferencesRepositoryImpl(context: persistence.mainContext)
    let notify = NoOpNotificationService()
    notify.authorization = .authorized

    let vm = NotificationSettingsViewModel(
      notificationService: notify,
      preferencesRepository: prefsRepo,
      notificationScheduler: NotificationScheduler(
        notificationService: notify,
        preferencesRepository: prefsRepo,
        taskRepository: MockTaskRepository()
      )
    )

    await vm.load()

    #expect(vm.authorization == .authorized)
    #expect(vm.preferences.sessionCompletionRemindersEnabled)
  }

  @Test
  func saveAndReschedulePersistsPreferences() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let prefsRepo = UserPreferencesRepositoryImpl(context: persistence.mainContext)
    let notify = NoOpNotificationService()
    notify.authorization = .authorized

    let vm = NotificationSettingsViewModel(
      notificationService: notify,
      preferencesRepository: prefsRepo,
      notificationScheduler: NotificationScheduler(
        notificationService: notify,
        preferencesRepository: prefsRepo,
        taskRepository: MockTaskRepository()
      )
    )

    await vm.load()
    vm.preferences.focusRemindersEnabled = false
    await vm.saveAndReschedule()

    let stored = try await prefsRepo.fetch()
    #expect(stored.notifications.focusRemindersEnabled == false)
  }
}
