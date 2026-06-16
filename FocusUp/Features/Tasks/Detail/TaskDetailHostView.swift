//
//  TaskDetailHostView.swift
//  FocusUp
//

import SwiftUI

/// Owns a stable `TaskDetailViewModel` and reloads after cold restore / navigation restoration.
struct TaskDetailHostView: View {
  @Environment(\.appContainer) private var container
  let taskID: UUID

  @State private var viewModel: TaskDetailViewModel?

  var body: some View {
    Group {
      if let viewModel {
        TaskDetailView(viewModel: viewModel)
      } else {
        taskDetailLoadingPlaceholder
      }
    }
    .onAppear(perform: ensureViewModel)
    .task(id: taskID) {
      await loadTask()
    }
    .onChange(of: container.coordinator.hasCompletedColdRestore) { _, isComplete in
      guard isComplete else { return }
      reloadTask()
    }
    .onChange(of: container.coordinator.navigationRestoreGeneration) { _, _ in
      reloadTask()
    }
  }

  private var taskDetailLoadingPlaceholder: some View {
    ScrollView {
      ReadableContentView {
        AppCard {
          HStack(spacing: AppSpacing.md) {
            ProgressView()
            Text("Loading task…")
              .appFont(.body)
              .foregroundStyle(AppColors.secondaryText)
          }
        }
        .adaptiveContentPadding()
      }
    }
    .background(AppColors.background)
    .navigationTitle("Task")
    .navigationBarTitleDisplayMode(.inline)
  }

  private func ensureViewModel() {
    guard viewModel == nil else { return }
    viewModel = TaskDetailViewModel(
      taskID: taskID,
      repository: container.taskRepository
    )
  }

  private func loadTask() async {
    ensureViewModel()
    guard let viewModel else { return }
    await viewModel.load()
  }

  private func reloadTask() {
    ensureViewModel()
    guard let viewModel else { return }
    _Concurrency.Task { await viewModel.load() }
  }
}
