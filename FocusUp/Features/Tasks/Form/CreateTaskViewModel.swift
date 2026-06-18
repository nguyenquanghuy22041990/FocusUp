//
//  CreateTaskViewModel.swift
//  FocusUp
//

import Foundation
import Observation

enum CreateTaskSubmissionState: Equatable {
  case idle
  case submitting
  case success
  case error(String)
}

@MainActor
@Observable
final class CreateTaskViewModel {
  private let repository: any TaskRepository

  var title = ""
  var description = ""
  var purpose = ""
  var hobbies = ""
  var deadline: Date?
  var priority: TaskPriority = .medium
  var milestones: [MilestoneDraft] = []

  var validation = CreateTaskValidationResult(fieldErrors: [:])
  var hasAttemptedSubmit = false
  var submissionState: CreateTaskSubmissionState = .idle

  var shouldPersistDraft: Bool {
    submissionState != .success && !exportDraft().isEmpty
  }

  var draftSnapshot: CreateTaskDraft {
    exportDraft()
  }

  var isSubmitting: Bool {
    submissionState == .submitting
  }

  init(repository: any TaskRepository) {
    self.repository = repository
  }

  func applyDraft(_ draft: CreateTaskDraft) {
    title = draft.title
    description = draft.description
    purpose = draft.purpose
    hobbies = draft.hobbies
    deadline = draft.deadline
    priority = draft.priority
    milestones = draft.milestones
  }

  func exportDraft() -> CreateTaskDraft {
    CreateTaskDraft(
      title: title,
      description: description,
      purpose: purpose,
      hobbies: hobbies,
      deadline: deadline,
      priority: priority,
      milestones: milestones,
      savedAt: .now
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

  func addMilestone() {
    milestones.append(MilestoneDraft())
  }

  func removeMilestone(id: UUID) {
    milestones.removeAll { $0.id == id }
  }

  func createTask() async -> Bool {
    hasAttemptedSubmit = true
    deadline = TaskFormMapping.normalizedDeadline(deadline)
    let result = validateForm()
    guard result.isValid else { return false }

    submissionState = .submitting

    do {
      let task = buildTask()
      try await repository.create(task)
      TaskUpdateNotifier.post(taskID: task.id)
      submissionState = .success
      return true
    } catch {
      submissionState = .error(error.localizedDescription)
      return false
    }
  }

  func resetAfterSuccess() {
    title = ""
    description = ""
    purpose = ""
    hobbies = ""
    deadline = nil
    priority = .medium
    milestones = []
    validation = CreateTaskValidationResult(fieldErrors: [:])
    hasAttemptedSubmit = false
    submissionState = .idle
  }

  func buildTask() -> Task {
    TaskFormMapping.buildTask(
      id: UUID(),
      title: title,
      description: description,
      purpose: purpose,
      hobbies: hobbies,
      deadline: deadline,
      priority: priority,
      status: .todo,
      milestones: milestones,
      createdAt: .now
    )
  }

  func errorMessage(for field: CreateTaskField) -> String? {
    guard hasAttemptedSubmit else { return nil }
    return validation.message(for: field)
  }
}
