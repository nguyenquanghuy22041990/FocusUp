//
//  TaskValidationTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

struct TaskValidationTests {
  @Test(.tags(.tasks))
  func emptyTitleFailsValidation() {
    #expect(throws: TaskValidationError.emptyTitle) {
      try TaskValidation.validate(title: "   ")
    }
  }

  @Test(.tags(.tasks))
  func validTitlePassesValidation() throws {
    try TaskValidation.validate(title: "Write brief")
  }
}
