//
//  NotificationPermissionViewModelTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

@MainActor
private final class NotificationPermissionTestService: NotificationService {
  var status: NotificationAuthorizationState = .notDetermined
  var requestResult: NotificationAuthorizationState?
  private(set) var openSettingsCalled = false

  func authorizationStatus() async -> NotificationAuthorizationState {
    status
  }

  func requestAuthorization() async -> NotificationAuthorizationState {
    let result = requestResult ?? status
    status = result
    return result
  }

  func openSystemSettings() {
    openSettingsCalled = true
  }

  func schedule(_ request: LocalNotificationRequest) async throws {}

  func cancel(identifiers: [String]) async {}

  func cancelAll() async {}

  func pendingIdentifiers() async -> [String] { [] }
}

@MainActor
@Suite(.tags(.notifications, .production))
struct NotificationPermissionViewModelTests {
  @Test
  func loadShowsEducationWhenNotDetermined() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let prefsRepo = UserPreferencesRepositoryImpl(context: persistence.mainContext)
    let service = NotificationPermissionTestService()
    service.status = .notDetermined

    let viewModel = NotificationPermissionViewModel(
      notificationService: service,
      preferencesRepository: prefsRepo
    )

    await viewModel.load()

    #expect(viewModel.step == .education)
  }

  @Test
  func loadShowsAuthorizedWhenAlreadyGranted() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let prefsRepo = UserPreferencesRepositoryImpl(context: persistence.mainContext)
    let service = NotificationPermissionTestService()
    service.status = .authorized

    let viewModel = NotificationPermissionViewModel(
      notificationService: service,
      preferencesRepository: prefsRepo
    )

    await viewModel.load()

    #expect(viewModel.step == .authorized)
  }

  @Test
  func loadShowsDeniedWhenPermissionBlocked() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let prefsRepo = UserPreferencesRepositoryImpl(context: persistence.mainContext)
    let service = NotificationPermissionTestService()
    service.status = .denied

    let viewModel = NotificationPermissionViewModel(
      notificationService: service,
      preferencesRepository: prefsRepo
    )

    await viewModel.load()

    #expect(viewModel.step == .denied)
  }

  @Test
  func requestPermissionCompletesOnAuthorization() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let prefsRepo = UserPreferencesRepositoryImpl(context: persistence.mainContext)
    let service = NotificationPermissionTestService()
    service.requestResult = .authorized

    let viewModel = NotificationPermissionViewModel(
      notificationService: service,
      preferencesRepository: prefsRepo
    )
    var completed = false
    viewModel.onCompleted = { completed = true }

    await viewModel.requestPermission()

    #expect(viewModel.step == .authorized)
    #expect(completed)
    let stored = try await prefsRepo.fetch()
    #expect(stored.notifications.hasSeenPermissionEducation)
  }

  @Test
  func requestPermissionShowsDeniedWhenUserDeclines() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let prefsRepo = UserPreferencesRepositoryImpl(context: persistence.mainContext)
    let service = NotificationPermissionTestService()
    service.requestResult = .denied

    let viewModel = NotificationPermissionViewModel(
      notificationService: service,
      preferencesRepository: prefsRepo
    )

    await viewModel.requestPermission()

    #expect(viewModel.step == .denied)
  }

  @Test
  func openSettingsDelegatesToService() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let prefsRepo = UserPreferencesRepositoryImpl(context: persistence.mainContext)
    let service = NotificationPermissionTestService()
    let viewModel = NotificationPermissionViewModel(
      notificationService: service,
      preferencesRepository: prefsRepo
    )

    viewModel.openSettings()

    #expect(service.openSettingsCalled)
  }

  @Test
  func continueWithoutNotificationsMarksEducationSeen() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let prefsRepo = UserPreferencesRepositoryImpl(context: persistence.mainContext)
    let service = NotificationPermissionTestService()
    let viewModel = NotificationPermissionViewModel(
      notificationService: service,
      preferencesRepository: prefsRepo
    )
    var completed = false
    viewModel.onCompleted = { completed = true }

    await viewModel.continueWithoutNotifications()

    #expect(completed)
    let stored = try await prefsRepo.fetch()
    #expect(stored.notifications.hasSeenPermissionEducation)
  }
}
