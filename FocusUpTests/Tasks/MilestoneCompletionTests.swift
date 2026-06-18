//
//  MilestoneCompletionTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

@MainActor
struct MilestoneCompletionTests {
  @Test(.tags(.tasks))
  func allMilestonesCompletedMarksTaskCompleted() async {
    var task = Task(
      title: "Milestones",
      status: .inProgress,
      milestones: [TaskMilestone(title: "Only", isCompleted: true)]
    )
    let repository = MockTaskRepository(tasks: [task])
    let viewModel = TaskDetailViewModel(taskID: task.id, repository: repository)
    await viewModel.load()

    await viewModel.toggleMilestoneCompletion(id: task.milestones[0].id)
    await viewModel.toggleMilestoneCompletion(id: task.milestones[0].id)

    #expect(viewModel.task?.status == .completed)
  }
}
