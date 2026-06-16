//
//  TaskListViewModelTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct TaskListViewModelTests {
  @Test(.tags(.tasks))
  func loadPopulatedState() async {
    let repository = MockTaskRepository(tasks: TaskPreviewData.list)
    let viewModel = TaskListViewModel(repository: repository)

    await viewModel.load()

  guard case .populated(let rows) = viewModel.state else {
      Issue.record("Expected populated state")
      return
    }
    #expect(!rows.isEmpty)
  }

  @Test(.tags(.tasks))
  func loadEmptyState() async {
    let repository = MockTaskRepository(tasks: [])
    let viewModel = TaskListViewModel(repository: repository)

    await viewModel.load()

    #expect(viewModel.state == .empty)
  }

  @Test(.tags(.tasks))
  func loadErrorState() async {
    let repository = MockTaskRepository()
    repository.error = NSError(domain: "test", code: 1)
    let viewModel = TaskListViewModel(repository: repository)

    await viewModel.load()

    guard case .error = viewModel.state else {
      Issue.record("Expected error state")
      return
    }
  }

  @Test(.tags(.tasks))
  func completedFilterShowsOnlyCompletedTasks() {
    let tasks = TaskPreviewData.list
    let filtered = TaskListViewModel.filter(tasks, route: .completed)
    #expect(filtered.allSatisfy { $0.status == .completed })
  }
}
