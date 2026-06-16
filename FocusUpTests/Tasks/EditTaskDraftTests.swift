//
//  EditTaskDraftTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

struct EditTaskDraftTests {
  @Test(.tags(.tasks))
  func editDraftStoreRoundTrip() {
    let taskID = UUID()
    let draft = EditTaskDraft(
      taskID: taskID,
      form: CreateTaskDraft(title: "Stored")
    )
    EditDraftStore.save(draft)
    let loaded = EditDraftStore.load(taskID: taskID)
    #expect(loaded?.form.title == "Stored")
    EditDraftStore.clear(taskID: taskID)
    #expect(EditDraftStore.load(taskID: taskID) == nil)
  }

  @Test(.tags(.tasks))
  func encodeDecodeEditDraft() throws {
    let taskID = UUID()
    let draft = EditTaskDraft(
      taskID: taskID,
      form: CreateTaskDraft(title: "Edited", savedAt: .now)
    )

    let data = try #require(FormDraftManager.encodeEdit(draft))
    let decoded = try #require(FormDraftManager.decodeEdit(data))

    #expect(decoded.taskID == taskID)
    #expect(decoded.form.title == "Edited")
  }
}
