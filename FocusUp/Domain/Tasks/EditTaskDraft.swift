//
//  EditTaskDraft.swift
//  FocusUp
//

import Foundation

struct EditTaskDraft: Codable, Equatable, Sendable {
  var taskID: UUID
  var form: CreateTaskDraft

  init(taskID: UUID, form: CreateTaskDraft) {
    self.taskID = taskID
    self.form = form
  }
}
