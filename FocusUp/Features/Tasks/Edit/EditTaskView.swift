//
//  EditTaskView.swift
//  FocusUp
//

import SwiftUI

struct EditTaskView: View {
  @Environment(\.appContainer) private var container
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.dismiss) private var dismiss
  @Bindable var viewModel: EditTaskViewModel
  var onSaved: () -> Void

  let taskID: UUID

  init(taskID: UUID, viewModel: EditTaskViewModel, onSaved: @escaping () -> Void) {
    self.taskID = taskID
    self.viewModel = viewModel
    self.onSaved = onSaved
  }

  private var showsLoadingPlaceholder: Bool {
    viewModel.submissionState == .loading && viewModel.title.isEmpty
  }

  var body: some View {
    Group {
      if showsLoadingPlaceholder {
        ProgressView("Loading task…")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if case .error(let message) = viewModel.submissionState, viewModel.title.isEmpty {
        errorState(message)
      } else {
        formContent
      }
    }
    .background(AppColors.background)
    .navigationTitle("Edit Task")
    .navigationBarTitleDisplayMode(.inline)
    .editTaskDraftRestoration(taskID: taskID, viewModel: viewModel)
    .task(id: EditTaskLoadTrigger(
      taskID: taskID,
      restorationReady: container.coordinator.hasCompletedColdRestore
    )) {
      await viewModel.load()
    }
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") { dismiss() }
          .frame(minHeight: AppSpacing.minimumTouchTarget)
      }
    }
  }

  private var formContent: some View {
    KeyboardDismissibleScrollView {
      ReadableContentView {
        VStack(alignment: .leading, spacing: AdaptiveSpacing.sectionSpacing(horizontalSizeClass: horizontalSizeClass)) {
          TaskFormContentView(
            title: $viewModel.title,
            description: $viewModel.description,
            purpose: $viewModel.purpose,
            hobbies: $viewModel.hobbies,
            deadline: $viewModel.deadline,
            priority: $viewModel.priority,
            milestones: $viewModel.milestones,
            errorMessage: viewModel.errorMessage(for:)
          )

          submitSection
        }
        .adaptiveContentPadding()
      }
    }
  }

  private var submitSection: some View {
    VStack(spacing: AppSpacing.md) {
      if case .error(let message) = viewModel.submissionState, !viewModel.title.isEmpty {
        Text(message)
          .appFont(.callout)
          .foregroundStyle(AppColors.error)
          .appMultilineText()
      }

      LoadingButton(
        title: "Save Changes",
        isLoading: viewModel.isSubmitting,
        isDisabled: viewModel.isSubmitting
      ) {
        _Concurrency.Task {
          let saved = await viewModel.saveChanges()
          if saved {
            EditDraftStore.clear(taskID: taskID)
            onSaved()
          }
        }
      }
    }
  }

  private func errorState(_ message: String) -> some View {
    VStack(spacing: AppSpacing.lg) {
      Text(message)
        .appFont(.body)
        .foregroundStyle(AppColors.secondaryText)
      SecondaryButton(title: "Try Again") {
        _Concurrency.Task { await viewModel.load() }
      }
    }
    .padding(AppSpacing.lg)
  }
}

private struct EditTaskLoadTrigger: Equatable {
  let taskID: UUID
  let restorationReady: Bool
}

#Preview {
  NavigationStack {
    EditTaskView(
      taskID: TaskPreviewData.list[0].id,
      viewModel: EditTaskViewModel(
        taskID: TaskPreviewData.list[0].id,
        repository: PreviewTaskRepository()
      ),
      onSaved: {}
    )
    .appContainer(.preview)
  }
}
