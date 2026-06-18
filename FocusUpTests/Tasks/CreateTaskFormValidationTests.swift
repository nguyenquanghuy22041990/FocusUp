//
//  CreateTaskFormValidationTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

struct CreateTaskFormValidationTests {
  @Test(.tags(.tasks))
  func emptyTitleFails() {
    let result = CreateTaskFormValidation.validate(
      title: "  ",
      description: "",
      purpose: "",
      hobbies: "",
      deadline: nil,
      milestones: []
    )
    #expect(result.message(for: .title) != nil)
  }

  @Test(.tags(.tasks))
  func startOfTodayDeadlinePasses() {
    let today = Calendar.current.startOfDay(for: .now)
    let result = CreateTaskFormValidation.validate(
      title: "Valid",
      description: "",
      purpose: "",
      hobbies: "",
      deadline: today,
      milestones: []
    )
    #expect(result.isValid)
  }

  @Test(.tags(.tasks))
  func pastDeadlineFails() {
    let calendar = Calendar.current
    let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now))!
    let result = CreateTaskFormValidation.validate(
      title: "Valid",
      description: "",
      purpose: "",
      hobbies: "",
      deadline: yesterday,
      milestones: []
    )
    #expect(result.message(for: .deadline) != nil)
  }

  @Test(.tags(.tasks))
  func emptyMilestoneRowFails() {
    let result = CreateTaskFormValidation.validate(
      title: "Valid",
      description: "",
      purpose: "",
      hobbies: "",
      deadline: nil,
      milestones: [MilestoneDraft(title: "")]
    )
    #expect(result.message(for: .milestones) != nil)
  }

  @Test(.tags(.tasks))
  func validFormPasses() {
    let result = CreateTaskFormValidation.validate(
      title: "Write brief",
      description: "Notes",
      purpose: "Focus",
      hobbies: "Reading",
      deadline: Calendar.current.date(byAdding: .day, value: 1, to: .now),
      milestones: [MilestoneDraft(title: "Step 1")]
    )
    #expect(result.isValid)
  }

  @Test(.tags(.tasks))
  func draftExpiration() {
    let old = Date().addingTimeInterval(-(8 * 24 * 60 * 60))
    #expect(CreateTaskFormValidation.isDraftExpired(savedAt: old))
    #expect(!CreateTaskFormValidation.isDraftExpired(savedAt: .now))
  }
}
