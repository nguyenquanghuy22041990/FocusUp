//
//  TasksRoute.swift
//  FocusUp
//

import Foundation

enum TasksRoute: Hashable, Codable, Sendable, Equatable {
  case today
  case upcoming
  case completed
  case create
  case edit(UUID)
  case detail(UUID)

  var id: String {
    switch self {
    case .today: "today"
    case .upcoming: "upcoming"
    case .completed: "completed"
    case .create: "create"
    case .edit(let uuid): "edit-\(uuid.uuidString)"
    case .detail(let uuid): uuid.uuidString
    }
  }

  var title: String {
    switch self {
    case .today: "Today"
    case .upcoming: "Upcoming"
    case .completed: "Completed"
    case .create: "New Task"
    case .edit: "Edit Task"
    case .detail: "Task Detail"
    }
  }

  var accessibilityLabel: String { title }

  static var filterCases: [TasksRoute] {
    [.today, .upcoming, .completed]
  }
}

extension TasksRoute: NavigationRoute {}
