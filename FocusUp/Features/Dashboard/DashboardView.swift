//
//  DashboardView.swift
//  FocusUp
//

import SwiftUI

struct DashboardView: View {
  @Environment(\.appContainer) private var container
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  @State private var viewModel: DashboardViewModel?

  var body: some View {
    @Bindable var tabCoordinator = container.coordinator.tabCoordinators.dashboard

    FeatureNavigationShell(coordinator: tabCoordinator) {
      dashboardRoot
    } destination: { route in
      dashboardDestination(for: route)
    }
  }

  @ViewBuilder
  private var dashboardRoot: some View {
    ResponsiveContainer(wide: horizontalSizeClass == .regular) {
      Group {
        if let viewModel {
          switch viewModel.loadingState {
          case .loading where viewModel.snapshot.statistics == .empty:
            ProgressView("Loading dashboard…")
              .frame(maxWidth: .infinity, minHeight: 200)
          case .failed(let message):
            DashboardErrorView(message: message) {
              _Concurrency.Task { await viewModel.refresh() }
            }
          default:
            DashboardContentView(
              viewModel: viewModel,
              coordinator: container.coordinator
            )
          }
        } else {
          ProgressView()
        }
      }
    }
    .navigationTitle("Dashboard")
    .navigationBarTitleDisplayMode(.large)
    .refreshable {
      await viewModel?.refresh()
    }
    .onAppear(perform: ensureViewModel)
    .task {
      await viewModel?.load()
    }
    .onChange(of: container.focusSessionManager.activeSession?.id) { _, _ in
      _Concurrency.Task { await viewModel?.onSessionContinuityChanged() }
    }
    .onChange(of: container.coordinator.hasCompletedColdRestore) { _, isComplete in
      guard isComplete else { return }
      _Concurrency.Task { await viewModel?.refresh() }
    }
    .onChange(of: container.restSessionManager.activeSession?.id) { _, _ in
      _Concurrency.Task { await viewModel?.onSessionContinuityChanged() }
    }
    .onChange(of: container.focusSessionManager.activeSession?.status) { _, _ in
      _Concurrency.Task { await viewModel?.onSessionContinuityChanged() }
    }
  }

  @ViewBuilder
  private func dashboardDestination(for route: DashboardRoute) -> some View {
    switch route {
    case .weeklyOverview, .insights:
      DashboardTabRedirectView(tab: .statistics, coordinator: container.coordinator)
    case .goals:
      DashboardTabRedirectView(tab: .tasks, coordinator: container.coordinator)
    }
  }

  private func ensureViewModel() {
    guard viewModel == nil else { return }
    viewModel = DashboardViewModel(
      orchestrator: DashboardOrchestrator(
        statisticsRepository: container.statisticsRepository,
        taskRepository: container.taskRepository,
        focusSessionManager: container.focusSessionManager,
        restSessionManager: container.restSessionManager
      )
    )
  }
}

#if DEBUG
#Preview("Populated") {
  DashboardContentView(
    viewModel: {
      let vm = DashboardViewModel(
        orchestrator: DashboardOrchestrator(
          statisticsRepository: PreviewStatisticsRepository(),
          taskRepository: PreviewTaskRepository(),
          focusSessionManager: FocusSessionManager(
            repository: PreviewFocusRepository(),
            ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
          ),
          restSessionManager: RestSessionManager(
            repository: PreviewRestRepository(),
            ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
          )
        )
      )
      vm.configureForPreview(snapshot: DashboardPreviewData.populated)
      return vm
    }(),
    coordinator: .preview
  )
  .padding()
  .background(AppColors.background)
  .focusMotionContext(appPrefersReducedMotion: false)
}

#Preview("Active focus") {
  DashboardContentView(
    viewModel: {
      let focusManager = FocusSessionManager(
        repository: PreviewFocusRepository(),
        ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
      )
      let session = FocusSession(
        title: "Deep work",
        plannedDurationSeconds: 25 * 60,
        elapsedSeconds: 8 * 60,
        status: .active,
        segmentStartedAt: .now,
        sessionStartedAt: .now,
        associatedTaskID: PreviewSampleData.sampleTasks.first?.id
      )
      let snapshot = TimerSnapshot(
        state: .running,
        configuration: TimerConfiguration(totalDurationSeconds: 25 * 60),
        accumulatedElapsedSeconds: 8 * 60,
        segmentStartedAt: .now,
        lastUpdatedAt: .now
      )
      focusManager.configureForPreview(session: session, timerSnapshot: snapshot)
      let vm = DashboardViewModel(
        orchestrator: DashboardOrchestrator(
          statisticsRepository: PreviewStatisticsRepository(),
          taskRepository: PreviewTaskRepository(),
          focusSessionManager: focusManager,
          restSessionManager: RestSessionManager(
            repository: PreviewRestRepository(),
            ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
          )
        )
      )
      vm.configureForPreview(
        snapshot: DashboardPreviewData.activeFocus,
        activeTaskTitle: PreviewSampleData.sampleTasks.first?.title
      )
      return vm
    }(),
    coordinator: .preview
  )
  .padding()
  .background(AppColors.background)
  .focusMotionContext(appPrefersReducedMotion: false)
}

#Preview("Overdue tasks") {
  DashboardContentView(
    viewModel: {
      let vm = DashboardViewModel(
        orchestrator: DashboardOrchestrator(
          statisticsRepository: PreviewStatisticsRepository(),
          taskRepository: PreviewTaskRepository(),
          focusSessionManager: FocusSessionManager(
            repository: PreviewFocusRepository(),
            ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
          ),
          restSessionManager: RestSessionManager(
            repository: PreviewRestRepository(),
            ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
          )
        )
      )
      vm.configureForPreview(snapshot: DashboardPreviewData.overdueTasks)
      return vm
    }(),
    coordinator: .preview
  )
  .padding()
  .background(AppColors.background)
}

#Preview("Completed day") {
  DashboardContentView(
    viewModel: {
      let vm = DashboardViewModel(
        orchestrator: DashboardOrchestrator(
          statisticsRepository: PreviewStatisticsRepository(),
          taskRepository: PreviewTaskRepository(),
          focusSessionManager: FocusSessionManager(
            repository: PreviewFocusRepository(),
            ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
          ),
          restSessionManager: RestSessionManager(
            repository: PreviewRestRepository(),
            ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
          )
        )
      )
      vm.configureForPreview(snapshot: DashboardPreviewData.completedDay)
      return vm
    }(),
    coordinator: .preview
  )
  .padding()
  .background(AppColors.background)
}

#Preview("Recovery") {
  DashboardContentView(
    viewModel: {
      let vm = DashboardViewModel(
        orchestrator: DashboardOrchestrator(
          statisticsRepository: PreviewStatisticsRepository(),
          taskRepository: PreviewTaskRepository(),
          focusSessionManager: FocusSessionManager(
            repository: PreviewFocusRepository(),
            ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
          ),
          restSessionManager: RestSessionManager(
            repository: PreviewRestRepository(),
            ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
          )
        )
      )
      vm.configureForPreview(snapshot: DashboardPreviewData.recovery)
      return vm
    }(),
    coordinator: .preview
  )
  .padding()
  .background(AppColors.background)
}

#Preview("iPad") {
  DashboardContentView(
    viewModel: {
      let vm = DashboardViewModel(
        orchestrator: DashboardOrchestrator(
          statisticsRepository: PreviewStatisticsRepository(),
          taskRepository: PreviewTaskRepository(),
          focusSessionManager: FocusSessionManager(
            repository: PreviewFocusRepository(),
            ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
          ),
          restSessionManager: RestSessionManager(
            repository: PreviewRestRepository(),
            ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
          )
        )
      )
      vm.configureForPreview(snapshot: DashboardPreviewData.populated)
      return vm
    }(),
    coordinator: .preview
  )
  .environment(\.horizontalSizeClass, .regular)
  .padding()
  .background(AppColors.background)
}

#Preview("Large type") {
  DashboardContentView(
    viewModel: {
      let vm = DashboardViewModel(
        orchestrator: DashboardOrchestrator(
          statisticsRepository: PreviewStatisticsRepository(),
          taskRepository: PreviewTaskRepository(),
          focusSessionManager: FocusSessionManager(
            repository: PreviewFocusRepository(),
            ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
          ),
          restSessionManager: RestSessionManager(
            repository: PreviewRestRepository(),
            ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
          )
        )
      )
      vm.configureForPreview(snapshot: DashboardPreviewData.populated)
      return vm
    }(),
    coordinator: .preview
  )
  .environment(\.dynamicTypeSize, .accessibility3)
  .padding()
  .background(AppColors.background)
}
#endif

#Preview {
  DashboardView()
    .appContainer(.preview)
}
