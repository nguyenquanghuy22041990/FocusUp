//
//  CreateTaskFormValidation.swift
//  FocusUp
//

import Foundation

enum CreateTaskField: String, CaseIterable, Sendable {
  case title
  case description
  case purpose
  case hobbies
  case deadline
  case milestones
}

struct CreateTaskValidationResult: Equatable, Sendable {
  var fieldErrors: [CreateTaskField: String]

  var isValid: Bool { fieldErrors.isEmpty }

  func message(for field: CreateTaskField) -> String? {
    fieldErrors[field]
  }
}

enum CreateTaskFormValidation {
  static let draftExpirationInterval: TimeInterval = 7 * 24 * 60 * 60

  static func validate(
    title: String,
    description: String,
    purpose: String,
    hobbies: String,
    deadline: Date?,
    milestones: [MilestoneDraft]
  ) -> CreateTaskValidationResult {
    var errors: [CreateTaskField: String] = [:]

    let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmedTitle.isEmpty {
      errors[.title] = "Title is required."
    } else if trimmedTitle.count > TaskValidation.maxTitleLength {
      errors[.title] = "Title must be \(TaskValidation.maxTitleLength) characters or fewer."
    }

    if description.count > 2_000 {
      errors[.description] = "Description is too long."
    }

    if purpose.count > 500 {
      errors[.purpose] = "Purpose is too long."
    }

    if hobbies.count > 500 {
      errors[.hobbies] = "Hobbies are too long."
    }

    if let deadline {
      let calendar = Calendar.current
      let deadlineDay = calendar.startOfDay(for: deadline)
      let startOfToday = calendar.startOfDay(for: .now)
      if deadlineDay < startOfToday {
        errors[.deadline] = "Deadline must be today or later."
      }
    }

    let nonEmptyMilestones = milestones.filter {
      !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    if milestones.count != nonEmptyMilestones.count {
      errors[.milestones] = "Remove empty milestones or add a title to each."
    }

    for milestone in nonEmptyMilestones {
      if milestone.title.count > TaskValidation.maxTitleLength {
        errors[.milestones] = "Milestone titles must be \(TaskValidation.maxTitleLength) characters or fewer."
        break
      }
    }

    return CreateTaskValidationResult(fieldErrors: errors)
  }

  static func isDraftExpired(savedAt: Date, now: Date = .now) -> Bool {
    now.timeIntervalSince(savedAt) > draftExpirationInterval
  }
}
