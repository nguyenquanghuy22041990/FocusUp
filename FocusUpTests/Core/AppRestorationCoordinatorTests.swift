//
//  AppRestorationCoordinatorTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct AppRestorationCoordinatorTests {
  @Test(.tags(.foundation, .production))
  func coldRestoreLoadsActiveSessionFromDatabase() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let repository = FocusRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()

    var session = DomainFixtures.focusSession(title: "Persisted", status: .active)
    session.segmentStartedAt = clock.now()
    session.sessionStartedAt = clock.now()
    try await repository.save(session)

    let container = AppContainer(
      persistence: persistence,
      coordinator: AppCoordinator(),
      repositories: .init(
        taskRepository: TaskRepositoryImpl(context: persistence.mainContext),
        focusRepository: repository,
        restRepository: RestRepositoryImpl(context: persistence.mainContext),
        statisticsRepository: StatisticsRepositoryImpl(context: persistence.mainContext),
        userPreferencesRepository: UserPreferencesRepositoryImpl(context: persistence.mainContext)
      ),
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer(),
      liveActivityManager: RecordingLiveActivityManager(),
      notificationService: NoOpNotificationService()
    )

    await AppRestorationCoordinator.performColdRestore(
      using: container,
      scene: .init()
    )

    #expect(container.coordinator.hasCompletedColdRestore)
    #expect(container.focusSessionManager.activeSession?.id == session.id)
  }

  @Test(.tags(.foundation, .production))
  func coldRestoreIsIdempotentForProcess() async throws {
    let container = AppContainer(
      persistence: try PersistenceController(inMemory: true),
      coordinator: AppCoordinator()
    )

    await AppRestorationCoordinator.performColdRestore(using: container, scene: .init())
    let firstFlag = container.coordinator.hasCompletedColdRestore

    await AppRestorationCoordinator.performColdRestore(using: container, scene: .init())
    #expect(firstFlag)
    #expect(container.coordinator.hasCompletedColdRestore)
  }

  @Test(.tags(.foundation, .navigation, .production))
  func reconcileAddsActiveSessionRouteOnFocusTab() {
    let coordinator = AppCoordinator(selectedTab: .focus)
    let focus = FocusSessionManager(
      repository: FocusRepositoryImpl(context: try! PersistenceController(inMemory: true).mainContext),
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )

    focus.configureForPreview(
      session: DomainFixtures.focusSession(status: .active),
      timerSnapshot: FocusPreviewData.activeTimerSnapshot
    )

    coordinator.reconcileNavigationWithSessions(
      focusManager: focus,
      restManager: RestSessionManager(
        repository: RestRepositoryImpl(context: try! PersistenceController(inMemory: true).mainContext),
        ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
      )
    )

    #expect(coordinator.tabCoordinators.focus.path.contains(.activeSession))
  }

  @Test(.tags(.foundation, .navigation, .production))
  func navigationBackupSurvivesForceQuitStyleReload() {
    let state = PersistedNavigationState(
      selectedTab: .tasks,
      dashboardPath: [],
      tasksPath: [.today],
      focusPath: [],
      statisticsPath: [],
      settingsPath: []
    )
    AppRestorationStore.saveNavigation(state)

    let restored = AppRestorationStore.loadNavigation()
    #expect(restored == state)
  }
}
