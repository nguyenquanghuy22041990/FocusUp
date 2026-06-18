//
//  EditDraftStore.swift
//  FocusUp
//

import Foundation

/// Scene-associated edit drafts via lightweight UserDefaults storage per task ID.
enum EditDraftStore {
  static func load(taskID: UUID) -> EditTaskDraft? {
    let key = FormDraftKeys.editTaskDraft(taskID: taskID)
    guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
    return FormDraftManager.decodeEdit(data)
  }

  static func save(_ draft: EditTaskDraft) {
    let key = FormDraftKeys.editTaskDraft(taskID: draft.taskID)
    guard let data = FormDraftManager.encodeEdit(draft) else { return }
    UserDefaults.standard.set(data, forKey: key)
  }

  static func clear(taskID: UUID) {
    UserDefaults.standard.removeObject(forKey: FormDraftKeys.editTaskDraft(taskID: taskID))
  }
}
