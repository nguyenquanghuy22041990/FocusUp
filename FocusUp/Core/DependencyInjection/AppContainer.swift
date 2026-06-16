//
//  AppContainer.swift
//  FocusUp
//

import SwiftData
import SwiftUI

/// Root dependency container. Grows with repositories and services as features land.
@MainActor
final class AppContainer {
    let persistence: PersistenceController
    let coordinator: AppCoordinator
    let repositories: Repositories
    let ambientSoundPlayer: any SessionAmbientSoundPlaying
    let liveActivityManager: any LiveActivityManaging
    let focusSessionManager: FocusSessionManager
    let restSessionManager: RestSessionManager
    let notificationService: any NotificationService
    let notificationScheduler: any NotificationScheduling
    let hapticFeedback: HapticFeedbackCoordinator

    var taskRepository: any TaskRepository { repositories.taskRepository }
    var focusRepository: any FocusRepository { repositories.focusRepository }
    var restRepository: any RestRepository { repositories.restRepository }
    var statisticsRepository: any StatisticsRepository { repositories.statisticsRepository }
    var userPreferencesRepository: any UserPreferencesRepository { repositories.userPreferencesRepository }

    init(
        persistence: PersistenceController,
        coordinator: AppCoordinator,
        repositories: Repositories? = nil,
        clock: any Clock = SystemClock(),
        ambientSoundPlayer: (any SessionAmbientSoundPlaying)? = nil,
        liveActivityManager: (any LiveActivityManaging)? = nil,
        notificationService: (any NotificationService)? = nil,
        notificationScheduler: (any NotificationScheduling)? = nil,
        hapticFeedback: HapticFeedbackCoordinator? = nil
    ) {
        let resolvedRepositories = repositories ?? .live(using: persistence)
        let soundPlayer = ambientSoundPlayer ?? SessionAmbientSoundPlayer()
        let resolvedNotifications = notificationService ?? NotificationServiceImpl()
        let resolvedScheduler = notificationScheduler ?? NotificationScheduler(
            notificationService: resolvedNotifications,
            preferencesRepository: resolvedRepositories.userPreferencesRepository,
            taskRepository: resolvedRepositories.taskRepository,
            clock: clock
        )

        self.persistence = persistence
        self.coordinator = coordinator
        self.repositories = resolvedRepositories
        self.ambientSoundPlayer = soundPlayer
        self.notificationService = resolvedNotifications
        self.notificationScheduler = resolvedScheduler
        self.hapticFeedback = hapticFeedback ?? HapticFeedbackCoordinator()
        self.hapticFeedback.prepare()
        let resolvedLiveActivities = liveActivityManager ?? Self.defaultLiveActivityManager()
        self.liveActivityManager = resolvedLiveActivities
        self.focusSessionManager = FocusSessionManager(
            repository: resolvedRepositories.focusRepository,
            clock: clock,
            ambientSoundPlayer: soundPlayer,
            liveActivityManager: resolvedLiveActivities,
            notificationScheduler: resolvedScheduler
        )
        self.restSessionManager = RestSessionManager(
            repository: resolvedRepositories.restRepository,
            clock: clock,
            ambientSoundPlayer: soundPlayer,
            liveActivityManager: resolvedLiveActivities
        )
    }

    convenience init() {
        self.init(persistence: .shared, coordinator: AppCoordinator())
    }

    private static func defaultLiveActivityManager() -> any LiveActivityManaging {
        #if canImport(ActivityKit) && os(iOS)
        LiveActivityManager()
        #else
        NoOpLiveActivityManager()
        #endif
    }

    static let live = AppContainer()

    static let preview: AppContainer = {
        let noopLive = NoOpLiveActivityManager()
        let noopNotify = NoOpNotificationService()
        let persistence = PersistenceController.preview
        let repos = Repositories.preview
        let sound = NoOpSessionAmbientSoundPlayer()
        let scheduler = NotificationScheduler(
            notificationService: noopNotify,
            preferencesRepository: repos.userPreferencesRepository,
            taskRepository: repos.taskRepository
        )
        return AppContainer(
            persistence: persistence,
            coordinator: .preview,
            repositories: repos,
            ambientSoundPlayer: sound,
            liveActivityManager: noopLive,
            notificationService: noopNotify,
            notificationScheduler: scheduler
        )
    }()

    static let testing: AppContainer = {
        let noopLive = NoOpLiveActivityManager()
        let noopNotify = NoOpNotificationService()
        let persistence = PersistenceController.testing
        let repos = Repositories.preview
        let scheduler = NotificationScheduler(
            notificationService: noopNotify,
            preferencesRepository: repos.userPreferencesRepository,
            taskRepository: repos.taskRepository
        )
        return AppContainer(
            persistence: persistence,
            coordinator: .testing,
            repositories: repos,
            ambientSoundPlayer: NoOpSessionAmbientSoundPlayer(),
            liveActivityManager: noopLive,
            notificationService: noopNotify,
            notificationScheduler: scheduler
        )
    }()
}

// MARK: - Environment

private struct AppContainerKey: EnvironmentKey {
    static let defaultValue: AppContainer = .preview
}

extension EnvironmentValues {
    var appContainer: AppContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}

extension View {
    func appContainer(_ container: AppContainer) -> some View {
        environment(\.appContainer, container)
            .environment(\.modelContext, container.persistence.mainContext)
            .hapticFeedback(container.hapticFeedback)
    }
}
