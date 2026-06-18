//
//  FormDraftKeys.swift
//  FocusUp
//

import Foundation

enum FormDraftKeys {
  static let createTaskDraft = "focusup.form.createTask.draft"

  static func editTaskDraft(taskID: UUID) -> String {
    "focusup.form.editTask.\(taskID.uuidString)"
  }
}
