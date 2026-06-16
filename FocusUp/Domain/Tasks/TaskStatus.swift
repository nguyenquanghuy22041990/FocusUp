//
//  TaskStatus.swift
//  FocusUp
//

import Foundation

enum TaskStatus: String, Codable, CaseIterable, Sendable, Identifiable {
  case todo
  case inProgress
  case completed
  case archived

  var id: String { rawValue }

  var title: String {
    switch self {
    case .todo: "To Do"
    case .inProgress: "In Progress"
    case .completed: "Completed"
    case .archived: "Archived"
    }
  }

  var isDone: Bool {
    self == .completed || self == .archived
  }
}
