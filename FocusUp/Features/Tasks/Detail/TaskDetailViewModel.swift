//
//  TaskDetailViewModel.swift
//  FocusUp
//

import Foundation
import Observation

enum TaskDetailViewState: Equatable {
  case loading
  case loaded
  case error(String)
}

@MainActor
@Observable
final class TaskDetailViewModel {
  private let repository: any TaskRepository
  let taskID: UUID

  var state: TaskDetailViewState = .loading
  var task: Task?
  var isUpdating = false

  init(taskID: UUID, repository: any TaskRepository) {
    self.taskID = taskID
    self.repository = repository
  }

  func load() async {
    if _Concurrency.Task.isCancelled { return }
    let shouldShowLoading = task == nil || state != .loaded
    if shouldShowLoading {
      state = .loading
    }
    do {
      guard let task = try await repository.fetch(id: taskID) else {
        guard !_Concurrency.Task.isCancelled else { return }
        self.task = nil
        state = .error("Task not found.")
        return
      }
      guard !_Concurrency.Task.isCancelled else { return }
      self.task = task
      state = .loaded
    } catch {
      guard !_Concurrency.Task.isCancelled else { return }
      state = .error(error.localizedDescription)
    }
  }

  func toggleMilestoneCompletion(id: UUID) async {
    guard var task, let index = task.milestones.firstIndex(where: { $0.id == id }) else { return }
    isUpdating = true
    defer { isUpdating = false }

    task.milestones[index].isCompleted.toggle()
    task.milestones[index].updatedAt = .now
    syncStatusWithProgress(&task)

    do {
      try await repository.updateMilestone(taskID: taskID, milestone: task.milestones[index])
      try await repository.update(task)
      self.task = task
      notifyTaskUpdated()
    } catch {
      state = .error(error.localizedDescription)
    }
  }

  func removeMilestone(id: UUID) async {
    guard var task else { return }
    isUpdating = true
    defer { isUpdating = false }

    task.milestones.removeAll { $0.id == id }
    syncStatusWithProgress(&task)

    do {
      try await repository.update(task)
      self.task = task
      notifyTaskUpdated()
    } catch {
      state = .error(error.localizedDescription)
    }
  }

  func addMilestone(title: String) async {
    let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, var task else { return }

    isUpdating = true
    defer { isUpdating = false }

    let milestone = TaskMilestone(title: trimmed)
    task.milestones.append(milestone)
    syncStatusWithProgress(&task)

    do {
      try await repository.update(task)
      self.task = task
      notifyTaskUpdated()
    } catch {
      state = .error(error.localizedDescription)
    }
  }

  func toggleTaskCompletion() async {
    guard var task else { return }
    isUpdating = true
    defer { isUpdating = false }

    task.status = task.isCompleted ? .inProgress : .completed
    task.updatedAt = .now

    do {
      try await repository.update(task)
      self.task = task
      notifyTaskUpdated()
    } catch {
      state = .error(error.localizedDescription)
    }
  }

  private func notifyTaskUpdated() {
    TaskUpdateNotifier.post(taskID: taskID)
  }

  private func syncStatusWithProgress(_ task: inout Task) {
    if task.milestones.isEmpty { return }
    let allDone = task.milestones.allSatisfy(\.isCompleted)
    if allDone {
      task.status = .completed
    } else if task.status == .completed {
      task.status = .inProgress
    }
  }
}
