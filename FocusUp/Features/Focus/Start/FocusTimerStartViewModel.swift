//
//  FocusTimerStartViewModel.swift
//  FocusUp
//

import Foundation
import Observation

enum FocusTimerStartViewState: Equatable {
  case ready
  case loadingTasks
  case starting
  case error(String)
}

@MainActor
@Observable
final class FocusTimerStartViewModel {
  private let sessionManager: FocusSessionManager
  private let taskRepository: any TaskRepository

  var state: FocusTimerStartViewState = .ready
  var selectedPreset: FocusDurationPreset = .thirty
  var selectedTask: Task?
  var availableTasks: [Task] = []
  var customTitle: String = ""

  init(
    sessionManager: FocusSessionManager,
    taskRepository: any TaskRepository
  ) {
    self.sessionManager = sessionManager
    self.taskRepository = taskRepository
  }

  var sessionTitle: String {
    let trimmed = customTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    if !trimmed.isEmpty {
      return trimmed
    }
    if let selectedTask {
      return selectedTask.title
    }
    return "Focus Session"
  }

  var canStart: Bool {
    state != .starting && sessionManager.activeSession == nil
  }

  var hasActiveSessionElsewhere: Bool {
    sessionManager.activeSession != nil
  }

  func loadTasks() async {
    if state != .starting {
      state = .loadingTasks
    }
    do {
      let tasks = try await taskRepository.fetchAll()
      availableTasks = tasks.filter { !$0.isCompleted }
      reconcileTaskSelection(with: tasks)
      state = .ready
    } catch {
      state = .error(error.localizedDescription)
    }
  }

  /// Syncs the linked task against fresh repository data (stale in-memory copies may still show `isCompleted == false`).
  func reconcileTaskSelection(with allTasks: [Task]) {
    guard let selectedID = selectedTask?.id else { return }
    guard let fresh = allTasks.first(where: { $0.id == selectedID }) else {
      clearLinkedTaskSelection()
      return
    }
    if fresh.isCompleted {
      clearLinkedTaskSelection()
      return
    }
    selectedTask = fresh
  }

  func clearLinkedTaskSelection() {
    if let title = selectedTask?.title, customTitle == title {
      customTitle = ""
    }
    selectedTask = nil
  }

  func selectPreset(_ preset: FocusDurationPreset) {
    selectedPreset = preset
  }

  func selectTask(_ task: Task?) {
    selectedTask = task
    syncCustomTitleFromSelectedTask()
  }

  /// Prefills the session name when a task is linked; leaves the field editable.
  func syncCustomTitleFromSelectedTask() {
    guard let selectedTask else { return }
    customTitle = selectedTask.title
  }

  func startSession() async -> Bool {
    guard canStart else { return false }
    state = .starting

    do {
      try await sessionManager.startSession(
        title: sessionTitle,
        durationSeconds: selectedPreset.durationSeconds,
        associatedTaskID: selectedTask?.id
      )
      state = .ready
      return true
    } catch {
      state = .error(error.localizedDescription)
      return false
    }
  }
}
