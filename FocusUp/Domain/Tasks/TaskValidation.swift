//
//  TaskValidation.swift
//  FocusUp
//

import Foundation

enum TaskValidationError: Error, Equatable, Sendable {
  case emptyTitle
  case titleTooLong(Int)
}

enum TaskValidation {
  static let maxTitleLength = 120

  static func validate(title: String) throws {
    let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty {
      throw TaskValidationError.emptyTitle
    }
    if trimmed.count > maxTitleLength {
      throw TaskValidationError.titleTooLong(trimmed.count)
    }
  }

  static func validate(_ task: Task) throws {
    try validate(title: task.title)
  }
}
