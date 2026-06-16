//
//  EditTaskHostView.swift
//  FocusUp
//

import SwiftUI

/// Owns a stable edit view model for the navigation destination.
struct EditTaskHostView: View {
  @Environment(\.appContainer) private var container
  let taskID: UUID
  var onSaved: () -> Void

  @State private var viewModel: EditTaskViewModel?

  var body: some View {
    Group {
      if let viewModel {
        EditTaskView(taskID: taskID, viewModel: viewModel, onSaved: onSaved)
      } else {
        ProgressView("Loading task…")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
    .task {
      ensureViewModel()
    }
    .onAppear(perform: ensureViewModel)
  }

  private func ensureViewModel() {
    guard viewModel == nil else { return }
    viewModel = EditTaskViewModel(
      taskID: taskID,
      repository: container.taskRepository
    )
  }
}
