//
//  NavigationRestorationModifier.swift
//  FocusUp
//

import SwiftUI

/// Binds app navigation state to SceneStorage for relaunch and multitasking recovery.
struct NavigationRestorationModifier: ViewModifier {
  @Environment(\.appContainer) private var container
  @Bindable var coordinator: AppCoordinator
  @SceneStorage(NavigationRestorationKeys.persistedState) private var persistedData: Data?
  @Environment(\.scenePhase) private var scenePhase

  @State private var didRestore = false

  func body(content: Content) -> some View {
    content
      .onAppear {
        restoreIfNeeded()
      }
      .onChange(of: container.coordinator.hasCompletedColdRestore) { _, isComplete in
        guard isComplete else { return }
        restoreIfNeeded()
      }
      .onChange(of: scenePhase) { _, newPhase in
        guard newPhase == .background || newPhase == .inactive else { return }
        persistCurrentState()
      }
      .onChange(of: coordinator.selectedTab) { _, _ in
        persistIfReady()
      }
      .onChange(of: coordinator.tabCoordinators.dashboard.path) { _, _ in
        persistIfReady()
      }
      .onChange(of: coordinator.tabCoordinators.tasks.path) { _, _ in
        persistIfReady()
      }
      .onChange(of: coordinator.tabCoordinators.focus.path) { _, _ in
        persistIfReady()
      }
      .onChange(of: coordinator.tabCoordinators.statistics.path) { _, _ in
        persistIfReady()
      }
      .onChange(of: coordinator.tabCoordinators.settings.path) { _, _ in
        persistIfReady()
      }
  }

  private func persistIfReady() {
    guard didRestore else { return }
    persistCurrentState()
  }

  private func restoreIfNeeded() {
    guard container.coordinator.hasCompletedColdRestore else { return }
    guard !didRestore else { return }
    defer { didRestore = true }

    let state = NavigationRestorationManager.decode(persistedData)
      ?? AppRestorationStore.loadNavigation()
    guard let state else { return }
    coordinator.applyRestorationState(state)
    coordinator.reconcileNavigationWithSessions(
      focusManager: container.focusSessionManager,
      restManager: container.restSessionManager
    )
    coordinator.navigationRestoreGeneration += 1
  }

  private func persistCurrentState() {
    let state = coordinator.exportRestorationState()
    persist(state)
  }

  private func persist(_ state: PersistedNavigationState) {
    persistedData = NavigationRestorationManager.encode(state)
    AppRestorationStore.saveNavigation(state)
  }
}

extension View {
  func navigationRestoration(coordinator: AppCoordinator) -> some View {
    modifier(NavigationRestorationModifier(coordinator: coordinator))
  }
}
