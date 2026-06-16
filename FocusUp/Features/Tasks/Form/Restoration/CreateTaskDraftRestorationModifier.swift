//
//  CreateTaskDraftRestorationModifier.swift
//  FocusUp
//

import SwiftUI

struct CreateTaskDraftRestorationModifier: ViewModifier {
  @Environment(\.appContainer) private var container
  @Bindable var viewModel: CreateTaskViewModel
  @SceneStorage(FormDraftKeys.createTaskDraft) private var draftData: Data?
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
        persistDraft()
      }
      .onChange(of: viewModel.draftSnapshot) { _, _ in
        persistIfReady()
      }
      .onChange(of: viewModel.shouldPersistDraft) { _, shouldPersist in
        guard didRestore, !shouldPersist else { return }
        draftData = nil
        AppRestorationStore.saveCreateTaskDraft(nil)
      }
  }

  private func restoreIfNeeded() {
    guard !didRestore else { return }
    defer { didRestore = true }

    let data = draftData ?? AppRestorationStore.loadCreateTaskDraft()
    guard let draft = FormDraftManager.decode(data) else { return }
    viewModel.applyDraft(draft)
  }

  private func persistIfReady() {
    guard didRestore, viewModel.shouldPersistDraft else { return }
    persistDraft()
  }

  private func persistDraft() {
    guard viewModel.shouldPersistDraft else {
      draftData = nil
      AppRestorationStore.saveCreateTaskDraft(nil)
      return
    }
    let data = FormDraftManager.encode(viewModel.exportDraft())
    draftData = data
    AppRestorationStore.saveCreateTaskDraft(data)
  }
}

extension View {
  func createTaskDraftRestoration(viewModel: CreateTaskViewModel) -> some View {
    modifier(CreateTaskDraftRestorationModifier(viewModel: viewModel))
  }
}
