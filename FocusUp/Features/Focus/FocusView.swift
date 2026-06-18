//
//  FocusView.swift
//  FocusUp
//

import SwiftUI

struct FocusView: View {
  @Environment(\.appContainer) private var container
  @State private var startViewModel: FocusTimerStartViewModel?
  @State private var timerViewModel: FocusTimerViewModel?
  @State private var restViewModel: RestTimerViewModel?

  var body: some View {
    @Bindable var coordinator = container.coordinator
    @Bindable var tabCoordinator = coordinator.tabCoordinators.focus

    FeatureNavigationShell(coordinator: tabCoordinator) {
      focusRoot(tabCoordinator: tabCoordinator)
    } destination: { route in
      destination(for: route, tabCoordinator: tabCoordinator)
    }
    .onAppear(perform: ensureViewModels)
    .onChange(of: coordinator.selectedTab) { _, tab in
      guard tab == .focus, let startViewModel else { return }
      _Concurrency.Task { await startViewModel.loadTasks() }
    }
    .onReceive(NotificationCenter.default.publisher(for: TaskUpdateNotifier.name)) { _ in
      guard coordinator.selectedTab == .focus, let startViewModel else { return }
      _Concurrency.Task { await startViewModel.loadTasks() }
    }
    .onChange(of: container.focusSessionManager.activeSession?.id) { _, newID in
      if newID == nil {
        container.coordinator.clearStaleFocusSessionRoutes(hasActiveSession: false)
      } else {
        scheduleRouteToActiveSessionIfNeeded(using: tabCoordinator)
      }
    }
    .onChange(of: container.restSessionManager.activeSession?.id) { _, newID in
      if newID == nil {
        container.coordinator.clearStaleRestSessionRoutes(hasActiveRestSession: false)
      } else {
        scheduleRouteToRestSessionIfNeeded(using: tabCoordinator)
      }
    }
  }

  @ViewBuilder
  private func focusRoot(tabCoordinator: TabCoordinator<FocusRoute>) -> some View {
    if let startViewModel {
      FocusTimerStartView(
        viewModel: startViewModel,
        onSessionStarted: { tabCoordinator.push(.activeSession) },
        onRestTapped: { tabCoordinator.push(.restSession) }
      )
      .task {
        scheduleRouteToActiveSessionIfNeeded(using: tabCoordinator)
        scheduleRouteToRestSessionIfNeeded(using: tabCoordinator)
      }
    } else {
      ProgressView()
    }
  }

  @ViewBuilder
  private func destination(
    for route: FocusRoute,
    tabCoordinator: TabCoordinator<FocusRoute>
  ) -> some View {
    switch route {
    case .sessionSetup:
      if let startViewModel {
        FocusTimerStartView(
          viewModel: startViewModel,
          onSessionStarted: { tabCoordinator.push(.activeSession) },
          onRestTapped: { tabCoordinator.push(.restSession) }
        )
      } else {
        ProgressView()
      }
    case .restSession:
      if let restViewModel {
        RestTimerView(
          viewModel: restViewModel,
          onSessionEnded: { tabCoordinator.popToRoot() }
        )
      } else {
        ProgressView()
      }
    case .activeSession:
      if let timerViewModel {
        FocusTimerView(
          viewModel: timerViewModel,
          onSessionEnded: { tabCoordinator.popToRoot() },
          onStartRest: { tabCoordinator.push(.restSession) }
        )
      } else {
        ProgressView()
      }
    case .history:
      PlaceholderDetailView(
        title: route.title,
        subtitle: "Session history will appear here.",
        systemImage: "clock.arrow.circlepath"
      )
    }
  }

  private func ensureViewModels() {
    if startViewModel == nil {
      startViewModel = FocusTimerStartViewModel(
        sessionManager: container.focusSessionManager,
        taskRepository: container.taskRepository
      )
    }
    if timerViewModel == nil {
      timerViewModel = FocusTimerViewModel(
        sessionManager: container.focusSessionManager,
        taskRepository: container.taskRepository
      )
    }
    if restViewModel == nil {
      restViewModel = RestTimerViewModel(sessionManager: container.restSessionManager)
    }
  }

  private func scheduleRouteToActiveSessionIfNeeded(using coordinator: TabCoordinator<FocusRoute>) {
    guard container.focusSessionManager.activeSession != nil else { return }
    guard !coordinator.path.contains(.activeSession) else { return }

    _Concurrency.Task { @MainActor in
      guard container.focusSessionManager.activeSession != nil else { return }
      guard !coordinator.path.contains(.activeSession) else { return }
      coordinator.push(.activeSession)
    }
  }

  private func scheduleRouteToRestSessionIfNeeded(using coordinator: TabCoordinator<FocusRoute>) {
    guard container.restSessionManager.activeSession != nil else { return }
    guard !coordinator.path.contains(.restSession) else { return }

    _Concurrency.Task { @MainActor in
      guard container.restSessionManager.activeSession != nil else { return }
      guard !coordinator.path.contains(.restSession) else { return }
      coordinator.push(.restSession)
    }
  }
}

#Preview {
  FocusView()
    .appContainer(.preview)
}
