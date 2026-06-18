//
//  TasksView.swift
//  FocusUp
//

import SwiftUI

struct TasksView: View {
  @Environment(\.appContainer) private var container
  @State private var listViewModel: TaskListViewModel?

  var body: some View {
    @Bindable var tabCoordinator = container.coordinator.tabCoordinators.tasks

    FeatureNavigationShell(coordinator: tabCoordinator) {
      ResponsiveContainer {
        if let listViewModel {
          TaskListView(viewModel: listViewModel)
        } else {
          ProgressView()
        }
      }
      .navigationTitle("Tasks")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          NavigationLink(value: TasksRoute.create) {
            Label("New Task", systemImage: "plus")
          }
          .frame(minHeight: AppSpacing.minimumTouchTarget)
          .accessibilityLabel("Create new task")
        }
      }
    } destination: { route in
      switch route {
      case .create:
        CreateTaskView(
          viewModel: CreateTaskViewModel(repository: container.taskRepository),
          onCreated: {
            _Concurrency.Task { await listViewModel?.load() }
          }
        )
      case .detail(let taskID):
        TaskDetailHostView(taskID: taskID)
      case .edit(let taskID):
        EditTaskHostView(taskID: taskID) {
          TaskUpdateNotifier.post(taskID: taskID)
          if tabCoordinator.path.last == .edit(taskID) {
            tabCoordinator.pop()
          }
          _Concurrency.Task { await listViewModel?.load() }
        }
      default:
        PlaceholderDetailView(
          title: route.title,
          subtitle: "Filtered task lists are shown on the main Tasks screen.",
          systemImage: "checklist"
        )
      }
    }
    .onAppear {
      if listViewModel == nil {
        listViewModel = TaskListViewModel(repository: container.taskRepository)
      }
    }
  }
}

#Preview("Populated") {
  TasksView()
    .appContainer(.preview)
}

#Preview("Empty") {
  let container = AppContainer(
    persistence: .preview,
    coordinator: .preview,
    repositories: AppContainer.Repositories(
      taskRepository: PreviewTaskRepositoryEmpty(),
      focusRepository: PreviewFocusRepository(),
      restRepository: PreviewRestRepository(),
      statisticsRepository: PreviewStatisticsRepository(),
      userPreferencesRepository: PreviewUserPreferencesRepository()
    )
  )
  TasksView()
    .appContainer(container)
}

#Preview("Dark") {
  TasksView()
    .appContainer(.preview)
    .preferredColorScheme(.dark)
}

#Preview("iPad") {
  TasksView()
    .appContainer(.preview)
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("Landscape", traits: .landscapeLeft) {
  TasksView()
    .appContainer(.preview)
}
