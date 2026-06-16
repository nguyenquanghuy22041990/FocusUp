//
//  TaskDetailView.swift
//  FocusUp
//

import SwiftUI

struct TaskDetailView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Bindable var viewModel: TaskDetailViewModel

  @State private var showAddMilestoneAlert = false
  @State private var newMilestoneTitle = ""

  var body: some View {
    ScrollView {
      ReadableContentView {
        content
          .adaptiveContentPadding()
      }
    }
    .background(AppColors.background)
    .navigationTitle(viewModel.task?.title ?? "Task")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      if viewModel.task != nil {
        ToolbarItem(placement: .topBarTrailing) {
          NavigationLink(value: TasksRoute.edit(viewModel.taskID)) {
            Text("Edit")
          }
          .frame(minHeight: AppSpacing.minimumTouchTarget)
          .accessibilityLabel("Edit task")
        }
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: TaskUpdateNotifier.name)) { output in
      guard let id = output.object as? UUID, id == viewModel.taskID else { return }
      _Concurrency.Task { await viewModel.load() }
    }
    .refreshable {
      await viewModel.load()
    }
    .alert("Add Milestone", isPresented: $showAddMilestoneAlert) {
      TextField("Milestone title", text: $newMilestoneTitle)
      Button("Cancel", role: .cancel) {
        newMilestoneTitle = ""
      }
      Button("Add") {
        let title = newMilestoneTitle
        newMilestoneTitle = ""
        _Concurrency.Task { await viewModel.addMilestone(title: title) }
      }
    } message: {
      Text("Enter a short milestone title.")
    }
  }

  @ViewBuilder
  private var content: some View {
    switch viewModel.state {
    case .loading:
      loadingView
    case .error(let message):
      errorView(message)
    case .loaded:
      if let task = viewModel.task {
        loadedContent(task)
      } else {
        errorView("Task not found.")
      }
    }
  }

  private var loadingView: some View {
    AppCard {
      HStack(spacing: AppSpacing.md) {
        ProgressView()
        Text("Loading task…")
          .appFont(.body)
          .foregroundStyle(AppColors.secondaryText)
      }
    }
  }

  private func loadedContent(_ task: Task) -> some View {
    VStack(alignment: .leading, spacing: AdaptiveSpacing.sectionSpacing(horizontalSizeClass: horizontalSizeClass)) {
      headerSection(task)
      TaskDetailProgressSection(
        progress: task.progress,
        completedCount: task.completedMilestoneCount,
        totalMilestones: task.milestones.count,
        isCompleted: task.isCompleted
      )
      overviewSection(task)
      TaskMilestoneManagementSection(
        milestones: task.milestones,
        onToggle: { id in
          _Concurrency.Task { await viewModel.toggleMilestoneCompletion(id: id) }
        },
        onRemove: { id in
          _Concurrency.Task { await viewModel.removeMilestone(id: id) }
        },
        onAdd: { showAddMilestoneAlert = true }
      )
      completionSection(task)
    }
    .disabled(viewModel.isUpdating)
  }

  private func headerSection(_ task: Task) -> some View {
    TaskDetailSection(title: "Overview") {
      VStack(alignment: .leading, spacing: AppSpacing.sm) {
        Text(task.title)
          .appFont(.largeTitle)
          .accessibilityAddTraits(.isHeader)

        HStack(spacing: AppSpacing.sm) {
          Text(task.priority.title)
            .appFont(.caption)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xxs)
            .background(AppColors.focus.opacity(0.15))
            .foregroundStyle(AppColors.focus)
            .clipShape(Capsule())

          Text(task.status.title)
            .appFont(.caption)
            .foregroundStyle(AppColors.secondaryText)
        }
      }
    }
  }

  private func overviewSection(_ task: Task) -> some View {
    TaskDetailSection(title: "Details") {
      VStack(alignment: .leading, spacing: AppSpacing.md) {
        TaskDetailMetadataRow(label: "Description", value: task.notes, isEmpty: task.notes.isEmpty)
        TaskDetailMetadataRow(label: "Purpose", value: task.purpose, isEmpty: task.purpose.isEmpty)
        TaskDetailMetadataRow(label: "Hobbies", value: task.hobbies, isEmpty: task.hobbies.isEmpty)
        TaskDetailMetadataRow(
          label: "Deadline",
          value: task.deadline.map(formattedDate) ?? "",
          isEmpty: task.deadline == nil
        )
      }
    }
  }

  private func completionSection(_ task: Task) -> some View {
    TaskDetailSection(title: "Completion") {
      Toggle(
        task.isCompleted ? "Mark as incomplete" : "Mark as complete",
        isOn: Binding(
          get: { task.isCompleted },
          set: { _ in
            _Concurrency.Task { await viewModel.toggleTaskCompletion() }
          }
        )
      )
      .appFont(.body)
      .frame(minHeight: AppSpacing.minimumTouchTarget)
    }
  }

  private func errorView(_ message: String) -> some View {
    AppCard {
      VStack(alignment: .leading, spacing: AppSpacing.sm) {
        Text(message)
          .appFont(.body)
          .foregroundStyle(AppColors.secondaryText)
        SecondaryButton(title: "Try Again") {
          _Concurrency.Task { await viewModel.load() }
        }
      }
    }
  }

  private func formattedDate(_ date: Date) -> String {
    date.formatted(date: .abbreviated, time: .omitted)
  }
}

#Preview("In Progress") {
  NavigationStack {
    TaskDetailView(
      viewModel: TaskDetailViewModel(
        taskID: TaskPreviewData.list[0].id,
        repository: PreviewTaskRepository()
      )
    )
    .appContainer(.preview)
  }
}

#Preview("Completed") {
  NavigationStack {
    TaskDetailView(
      viewModel: TaskDetailViewModel(
        taskID: TaskPreviewData.list[2].id,
        repository: PreviewTaskRepository()
      )
    )
    .appContainer(.preview)
  }
}

#Preview("iPad") {
  NavigationStack {
    TaskDetailView(
      viewModel: TaskDetailViewModel(
        taskID: TaskPreviewData.list[0].id,
        repository: PreviewTaskRepository()
      )
    )
    .appContainer(.preview)
    .environment(\.horizontalSizeClass, .regular)
  }
}

#Preview("Dark") {
  NavigationStack {
    TaskDetailView(
      viewModel: TaskDetailViewModel(
        taskID: TaskPreviewData.list[0].id,
        repository: PreviewTaskRepository()
      )
    )
    .appContainer(.preview)
    .preferredColorScheme(.dark)
  }
}
