//
//  CreateTaskView.swift
//  FocusUp
//

import SwiftUI

struct CreateTaskView: View {
  @Environment(\.appContainer) private var container
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.dismiss) private var dismiss
  @Bindable var viewModel: CreateTaskViewModel
  var onCreated: () -> Void

  var body: some View {
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
    .background(AppColors.background)
    .navigationTitle("New Task")
    .navigationBarTitleDisplayMode(.inline)
    .createTaskDraftRestoration(viewModel: viewModel)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") { dismiss() }
          .frame(minHeight: AppSpacing.minimumTouchTarget)
      }
    }
  }

  private var submitSection: some View {
    VStack(spacing: AppSpacing.md) {
      if case .error(let message) = viewModel.submissionState {
        Text(message)
          .appFont(.callout)
          .foregroundStyle(AppColors.error)
          .appMultilineText()
          .focusValidationTransition(message: message)
          .accessibilityLabel("Error: \(message)")
      }

      LoadingButton(
        title: "Create Task",
        isLoading: viewModel.isSubmitting,
        isDisabled: viewModel.isSubmitting
      ) {
        _Concurrency.Task { @MainActor in
          let created = await viewModel.createTask()
          if created {
            container.hapticFeedback.success()
            viewModel.resetAfterSuccess()
            onCreated()
            dismiss()
          }
        }
      }
    }
  }
}

#Preview("Empty") {
  NavigationStack {
    CreateTaskView(
      viewModel: CreateTaskViewModel(repository: PreviewTaskRepository()),
      onCreated: {}
    )
    .appContainer(.preview)
  }
}

#Preview("Populated") {
  let viewModel = CreateTaskViewModel(repository: PreviewTaskRepository())
  viewModel.title = "Plan focus week"
  viewModel.description = "Outline weekly goals"
  viewModel.purpose = "Stay intentional"
  viewModel.milestones = [MilestoneDraft(title: "Review calendar")]
  return NavigationStack {
    CreateTaskView(viewModel: viewModel, onCreated: {})
      .appContainer(.preview)
  }
}

#Preview("Validation") {
  let viewModel = CreateTaskViewModel(repository: PreviewTaskRepository())
  viewModel.hasAttemptedSubmit = true
  _ = viewModel.validateForm()
  return NavigationStack {
    CreateTaskView(viewModel: viewModel, onCreated: {})
      .appContainer(.preview)
  }
}

#Preview("Dark") {
  NavigationStack {
    CreateTaskView(
      viewModel: CreateTaskViewModel(repository: PreviewTaskRepository()),
      onCreated: {}
    )
    .appContainer(.preview)
    .preferredColorScheme(.dark)
  }
}

#Preview("iPad") {
  NavigationStack {
    CreateTaskView(
      viewModel: CreateTaskViewModel(repository: PreviewTaskRepository()),
      onCreated: {}
    )
    .appContainer(.preview)
    .environment(\.horizontalSizeClass, .regular)
  }
}

#Preview("Large Text") {
  NavigationStack {
    CreateTaskView(
      viewModel: CreateTaskViewModel(repository: PreviewTaskRepository()),
      onCreated: {}
    )
    .appContainer(.preview)
    .environment(\.dynamicTypeSize, .accessibility3)
  }
}
