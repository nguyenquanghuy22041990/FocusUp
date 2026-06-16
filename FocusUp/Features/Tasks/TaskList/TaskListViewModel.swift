//
//  TaskListViewModel.swift
//  FocusUp
//

import Foundation
import Observation

enum TaskListViewState: Equatable {
  case loading
  case empty
  case populated([TaskRowModel])
  case error(String)
}

struct TaskRowModel: Identifiable, Equatable, Sendable {
  let id: UUID
  let task: Task

  var title: String { task.title }
  var subtitle: String { task.notes }
  var isCompleted: Bool { task.isCompleted }
  var progress: Double { task.progress }
  var milestoneSummary: String? {
    guard !task.milestones.isEmpty else { return nil }
    return "\(task.completedMilestoneCount) of \(task.milestones.count) milestones"
  }
}

@MainActor
@Observable
final class TaskListViewModel {
  private let repository: any TaskRepository

  var state: TaskListViewState = .loading
  var selectedFilter: TasksRoute = .today

  init(repository: any TaskRepository) {
    self.repository = repository
  }

  func load() async {
    state = .loading

    do {
      let tasks = try await repository.fetchAll()
      let filtered = Self.filter(tasks, route: selectedFilter)
      let rows = filtered.map { TaskRowModel(id: $0.id, task: $0) }
      state = rows.isEmpty ? .empty : .populated(rows)
    } catch {
      state = .error(error.localizedDescription)
    }
  }

  func selectFilter(_ route: TasksRoute) {
    guard TasksRoute.filterCases.contains(where: { $0 == route }) else { return }
    selectedFilter = route
  }

  func delete(taskID: UUID) async {
    do {
      try await repository.delete(id: taskID)
      TaskUpdateNotifier.post(taskID: taskID)
      await load()
    } catch {
      state = .error(error.localizedDescription)
    }
  }

  static func filter(_ tasks: [Task], route: TasksRoute) -> [Task] {
    switch route {
    case .today:
      return tasks.filter { $0.status == .todo || $0.status == .inProgress }
    case .upcoming:
      return tasks.filter { $0.status == .todo }
    case .completed:
      return tasks.filter { $0.status == .completed }
    case .create, .edit, .detail:
      return tasks
    }
  }
}
