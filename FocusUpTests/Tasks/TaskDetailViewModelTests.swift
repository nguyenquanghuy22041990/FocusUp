//
//  TaskDetailViewModelTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct TaskDetailViewModelTests {
  @Test(.tags(.tasks))
  func toggleMilestoneUpdatesCompletion() async {
    let task = Task(
      title: "Test",
      milestones: [
        TaskMilestone(title: "A"),
        TaskMilestone(title: "B")
      ]
    )
    let repository = MockTaskRepository(tasks: [task])
    let viewModel = TaskDetailViewModel(taskID: task.id, repository: repository)

    await viewModel.load()
    let milestoneID = task.milestones[0].id
    await viewModel.toggleMilestoneCompletion(id: milestoneID)

    #expect(viewModel.task?.milestones.first(where: { $0.id == milestoneID })?.isCompleted == true)
  }

  @Test(.tags(.tasks))
  func loadIgnoresCancellationWithoutLeavingLoadedState() async {
    let task = Task(title: "Cancel test")
    let repository = MockTaskRepository(tasks: [task])
    let viewModel = TaskDetailViewModel(taskID: task.id, repository: repository)

    let loadTask = _Concurrency.Task {
      await viewModel.load()
    }
    loadTask.cancel()
    _ = await loadTask.result

    await viewModel.load()
    #expect(viewModel.state == .loaded)
    #expect(viewModel.task?.id == task.id)
  }

  @Test(.tags(.tasks))
  func addMilestoneAppendsToTask() async {
    let task = Task(title: "Test")
    let repository = MockTaskRepository(tasks: [task])
    let viewModel = TaskDetailViewModel(taskID: task.id, repository: repository)

    await viewModel.load()
    await viewModel.addMilestone(title: "New step")

    #expect(viewModel.task?.milestones.count == 1)
    #expect(viewModel.task?.milestones.first?.title == "New step")
  }

  @Test(.tags(.tasks))
  func loadMissingTaskSetsErrorState() async {
    let viewModel = TaskDetailViewModel(
      taskID: UUID(),
      repository: MockTaskRepository()
    )

    await viewModel.load()

    guard case .error = viewModel.state else {
      Issue.record("Expected error state")
      return
    }
  }

  @Test(.tags(.tasks))
  func removeMilestoneUpdatesTask() async {
    let milestone = TaskMilestone(title: "Step")
    let task = Task(title: "Test", milestones: [milestone])
    let repository = MockTaskRepository(tasks: [task])
    let viewModel = TaskDetailViewModel(taskID: task.id, repository: repository)

    await viewModel.load()
    await viewModel.removeMilestone(id: milestone.id)

    #expect(viewModel.task?.milestones.isEmpty == true)
  }

  @Test(.tags(.tasks))
  func toggleTaskCompletionMarksComplete() async {
    let task = Task(title: "Complete me")
    let repository = MockTaskRepository(tasks: [task])
    let viewModel = TaskDetailViewModel(taskID: task.id, repository: repository)

    await viewModel.load()
    await viewModel.toggleTaskCompletion()

    #expect(viewModel.task?.isCompleted == true)
  }

  @Test(.tags(.tasks))
  func addMilestoneIgnoresBlankTitle() async {
    let task = Task(title: "Test")
    let repository = MockTaskRepository(tasks: [task])
    let viewModel = TaskDetailViewModel(taskID: task.id, repository: repository)

    await viewModel.load()
    await viewModel.addMilestone(title: "   ")

    #expect(viewModel.task?.milestones.isEmpty == true)
  }
}
