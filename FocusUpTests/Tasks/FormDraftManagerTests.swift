//
//  FormDraftManagerTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

struct FormDraftManagerTests {
  @Test(.tags(.tasks))
  func encodeDecodeRoundTrip() throws {
    let draft = CreateTaskDraft(
      title: "Draft task",
      description: "Notes",
      purpose: "Why",
      hobbies: "Run",
      priority: .high,
      milestones: [MilestoneDraft(title: "Step")]
    )

    let data = try #require(FormDraftManager.encode(draft))
    let decoded = try #require(FormDraftManager.decode(data))

    #expect(decoded.title == draft.title)
    #expect(decoded.milestones.count == 1)
  }

  @Test(.tags(.tasks))
  func expiredDraftReturnsNil() {
    let draft = CreateTaskDraft(
      title: "Old",
      savedAt: Date().addingTimeInterval(-(8 * 24 * 60 * 60))
    )
    let data = FormDraftManager.encode(draft)
    #expect(FormDraftManager.decode(data) == nil)
  }
}
