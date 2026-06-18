//
//  AppRestorationCoordinator.swift
//  FocusUp
//

import Foundation

/// Single cold-restore pipeline: sessions first, navigation second, reconcile last.
@MainActor
enum AppRestorationCoordinator {
  struct SceneSnapshots {
    var focusTimerData: Data?
    var restTimerData: Data?
  }

  static func performColdRestore(
    using container: AppContainer,
    scene: SceneSnapshots
  ) async {
    guard !container.coordinator.hasCompletedColdRestore else { return }

    // 1. Authoritative session state from SwiftData.
    await container.focusSessionManager.restoreOnLaunch()
    await container.restSessionManager.restoreOnLaunch()

    // 2. Refine timers from scene or app-wide backup (never before DB restore).
    await applyTimerSnapshotIfNeeded(
      manager: container.focusSessionManager,
      sceneData: scene.focusTimerData,
      backupData: AppRestorationStore.loadFocusTimerSnapshot()
    )
    await applyTimerSnapshotIfNeeded(
      manager: container.restSessionManager,
      sceneData: scene.restTimerData,
      backupData: AppRestorationStore.loadRestTimerSnapshot()
    )

    // 3. Navigation is restored per-scene in NavigationRestorationModifier after this flag flips.
    container.coordinator.reconcileNavigationWithSessions(
      focusManager: container.focusSessionManager,
      restManager: container.restSessionManager
    )

    container.coordinator.hasCompletedColdRestore = true

    await container.notificationScheduler.rescheduleAll()
    await AppForegroundRefresh.perform(using: container)
  }

  private static func applyTimerSnapshotIfNeeded<Manager>(
    manager: Manager,
    sceneData: Data?,
    backupData: Data?
  ) async where Manager: SessionTimerRestoring {
    let data = sceneData ?? backupData
    guard let snapshot = TimerRestorationManager.decode(data) else { return }

    if let activeID = manager.activeSessionID {
      guard activeID == snapshot.sessionID else { return }
      let currentElapsed = manager.timerElapsedSeconds
      let sceneElapsed = snapshot.timerSnapshot.elapsedSeconds(at: .now)
      guard sceneElapsed >= currentElapsed else { return }
    }

    await manager.applyRestorationSnapshot(snapshot)
  }
}

/// Shared restoration surface for focus and rest session managers.
@MainActor
protocol SessionTimerRestoring: AnyObject {
  var activeSessionID: UUID? { get }
  var timerElapsedSeconds: Int { get }
  func applyRestorationSnapshot(_ snapshot: SessionTimerRestorationSnapshot) async
}

extension FocusSessionManager: SessionTimerRestoring {
  var activeSessionID: UUID? { activeSession?.id }
  var timerElapsedSeconds: Int { timerEngine.elapsedSeconds() }
}

extension RestSessionManager: SessionTimerRestoring {
  var activeSessionID: UUID? { activeSession?.id }
  var timerElapsedSeconds: Int { timerEngine.elapsedSeconds() }
}
