//
//  AppRootView.swift
//  FocusUp
//

import SwiftUI

struct AppRootView: View {
  @Environment(\.appContainer) private var container
  @Environment(\.scenePhase) private var scenePhase
  @State private var appPrefersReducedMotion = false
  @State private var hapticsEnabled = true

  @SceneStorage(TimerRestorationKeys.focusTimerSnapshot) private var focusTimerSceneData: Data?
  @SceneStorage(TimerRestorationKeys.restTimerSnapshot) private var restTimerSceneData: Data?

  var body: some View {
    RootTabView(coordinator: container.coordinator)
      .navigationRestoration(coordinator: container.coordinator)
      .focusMotionContext(appPrefersReducedMotion: appPrefersReducedMotion)
      .environment(\.hapticsEnabled, hapticsEnabled)
      .task {
        await performColdStart()
      }
      .onReceive(NotificationCenter.default.publisher(for: TaskUpdateNotifier.name)) { _ in
        guard container.coordinator.hasCompletedColdRestore else { return }
        _Concurrency.Task {
          await container.notificationScheduler.rescheduleAll()
        }
      }
      .onChange(of: scenePhase) { _, newPhase in
        switch newPhase {
        case .active:
          guard container.coordinator.hasCompletedColdRestore else { return }
          _Concurrency.Task {
            await AppForegroundRefresh.perform(using: container)
          }
        case .background, .inactive:
          _Concurrency.Task {
            await AppForegroundRefresh.dismissLiveActivitiesWhenNoActiveSession(using: container)
          }
        default:
          break
        }
      }
      .focusTimerRestoration(manager: container.focusSessionManager)
      .restTimerRestoration(manager: container.restSessionManager)
  }

  private func performColdStart() async {
    await AppRestorationCoordinator.performColdRestore(
      using: container,
      scene: AppRestorationCoordinator.SceneSnapshots(
        focusTimerData: focusTimerSceneData,
        restTimerData: restTimerSceneData
      )
    )
    await syncMotionAndHapticPreferences()
  }

  private func syncMotionAndHapticPreferences() async {
    guard let preferences = try? await container.userPreferencesRepository.fetch() else { return }
    appPrefersReducedMotion = preferences.prefersReducedMotion
    hapticsEnabled = preferences.hapticsEnabled
    container.hapticFeedback.isEnabled = preferences.hapticsEnabled
  }
}

#Preview {
  AppRootView()
    .appContainer(.preview)
}
