//
//  EditTaskDraftRestorationModifier.swift
//  FocusUp
//

import SwiftUI

struct EditTaskDraftRestorationModifier: ViewModifier {
  let taskID: UUID
  @Bindable var viewModel: EditTaskViewModel
  @Environment(\.scenePhase) private var scenePhase

  @State private var didFinishInitialLoad = false

  func body(content: Content) -> some View {
    content
      .onChange(of: viewModel.submissionState) { _, newState in
        guard newState == .idle, !didFinishInitialLoad else { return }
        didFinishInitialLoad = true
      }
      .onChange(of: scenePhase) { _, newPhase in
        guard newPhase == .background || newPhase == .inactive else { return }
        persistDraft()
      }
      .onChange(of: viewModel.draftSnapshot) { _, _ in
        persistIfReady()
      }
  }

  private func persistIfReady() {
    guard didFinishInitialLoad, viewModel.shouldPersistDraft else { return }
    persistDraft()
  }

  private func persistDraft() {
    guard viewModel.shouldPersistDraft else {
      EditDraftStore.clear(taskID: taskID)
      return
    }
    EditDraftStore.save(viewModel.exportDraft())
  }
}

extension View {
  func editTaskDraftRestoration(taskID: UUID, viewModel: EditTaskViewModel) -> some View {
    modifier(EditTaskDraftRestorationModifier(taskID: taskID, viewModel: viewModel))
  }
}
