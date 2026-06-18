//
//  EditTaskViewModel.swift
//  FocusUp
//

import Foundation
import Observation

enum EditTaskSubmissionState: Equatable {
  case idle
  case loading
  case submitting
  case success
  case error(String)
}

@MainActor
@Observable
final class EditTaskViewModel {
  private let repository: any TaskRepository
  let taskID: UUID

  private var createdAt: Date = .now
  private var status: TaskStatus = .todo
  private var loadedMilestones: [TaskMilestone] = []

  var title = ""
  var description = ""
  var purpose = ""
  var hobbies = ""
  var deadline: Date?
  var priority: TaskPriority = .medium
  var milestones: [MilestoneDraft] = []

  var validation = CreateTaskValidationResult(fieldErrors: [:])
  var hasAttemptedSubmit = false
  var submissionState: EditTaskSubmissionState = .loading

  var shouldPersistDraft: Bool {
    submissionState != .success && submissionState != .loading && !exportDraft().form.isEmpty
  }

  var draftSnapshot: EditTaskDraft {
    exportDraft()
  }

  var isSubmitting: Bool {
    submissionState == .submitting
  }

  init(taskID: UUID, repository: any TaskRepository) {
    self.taskID = taskID
    self.repository = repository
  }

  func load() async {
    if _Concurrency.Task.isCancelled { return }
    let shouldShowLoading = title.isEmpty
    if shouldShowLoading {
      submissionState = .loading
    }
    do {
      guard let task = try await repository.fetch(id: taskID) else {
        guard !_Concurrency.Task.isCancelled else { return }
        submissionState = .error("Task not found.")
        return
      }
      guard !_Concurrency.Task.isCancelled else { return }
      applyTask(task)
      applyPersistedDraftIfAvailable(relativeTo: task)
      submissionState = .idle
    } catch {
      guard !_Concurrency.Task.isCancelled else { return }
      submissionState = .error(error.localizedDescription)
    }
  }

  /// Applies a saved in-progress draft only when it is newer than the persisted task.
  func applyPersistedDraftIfAvailable(relativeTo task: Task) {
    guard let draft = EditDraftStore.load(taskID: taskID), draft.taskID == taskID else { return }
    if CreateTaskFormValidation.isDraftExpired(savedAt: draft.form.savedAt) {
      EditDraftStore.clear(taskID: taskID)
      return
    }
    guard draft.form.savedAt > task.updatedAt else {
      EditDraftStore.clear(taskID: taskID)
      return
    }
    applyDraft(draft.form)
    loadedMilestones = TaskFormMapping.draftsToMilestones(
      draft.form.milestones,
      preserving: task.milestones
    )
  }

  func applyTask(_ task: Task) {
    createdAt = task.createdAt
    status = task.status
    loadedMilestones = task.milestones
    var form = CreateTaskDraft()
    TaskFormMapping.apply(task: task, to: &form)
    applyDraft(form)
  }

  func applyDraft(_ draft: CreateTaskDraft) {
    title = draft.title
    description = draft.description
    purpose = draft.purpose
    hobbies = draft.hobbies
    deadline = TaskFormMapping.normalizedDeadline(draft.deadline)
    priority = draft.priority
    milestones = draft.milestones
  }

  func exportDraft() -> EditTaskDraft {
    EditTaskDraft(
      taskID: taskID,
      form: CreateTaskDraft(
        title: title,
        description: description,
        purpose: purpose,
        hobbies: hobbies,
        deadline: deadline,
        priority: priority,
        milestones: milestones,
        savedAt: .now
      )
    )
  }

  func validateForm() -> CreateTaskValidationResult {
    let result = CreateTaskFormValidation.validate(
      title: title,
      description: description,
      purpose: purpose,
      hobbies: hobbies,
      deadline: deadline,
      milestones: milestones
    )
    validation = result
    return result
  }

  func saveChanges() async -> Bool {
    hasAttemptedSubmit = true
    deadline = TaskFormMapping.normalizedDeadline(deadline)
    milestones.removeAll {
      $0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    let result = validateForm()
    guard result.isValid else { return false }

    submissionState = .submitting

    do {
      let task = buildTask()
      try await repository.update(task)
      submissionState = .success
      return true
    } catch {
      submissionState = .error(error.localizedDescription)
      return false
    }
  }

  func buildTask() -> Task {
    TaskFormMapping.buildTask(
      id: taskID,
      title: title,
      description: description,
      purpose: purpose,
      hobbies: hobbies,
      deadline: deadline,
      priority: priority,
      status: status,
      milestones: milestones,
      existingMilestones: loadedMilestones,
      createdAt: createdAt
    )
  }

  func errorMessage(for field: CreateTaskField) -> String? {
    guard hasAttemptedSubmit else { return nil }
    return validation.message(for: field)
  }
}
