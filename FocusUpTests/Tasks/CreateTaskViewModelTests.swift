//
//  CreateTaskViewModelTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

@MainActor
struct CreateTaskViewModelTests {
  @Test(.tags(.tasks))
  func validateFormSetsErrors() {
    let viewModel = CreateTaskViewModel(repository: MockTaskRepository())
    viewModel.hasAttemptedSubmit = true
    let result = viewModel.validateForm()
    #expect(!result.isValid)
    #expect(viewModel.errorMessage(for: .title) != nil)
  }

  @Test(.tags(.tasks))
  func createTaskSuccess() async {
    let repository = MockTaskRepository()
    let viewModel = CreateTaskViewModel(repository: repository)
    viewModel.title = "New task"
    viewModel.description = "Details"

    let created = await viewModel.createTask()

    #expect(created)
    #expect(viewModel.submissionState == .success)
    #expect(repository.createCallCount == 1)
    #expect(repository.tasks.first?.title == "New task")
  }

  @Test(.tags(.tasks))
  func createTaskFailsValidation() async {
    let repository = MockTaskRepository()
    let viewModel = CreateTaskViewModel(repository: repository)

    let created = await viewModel.createTask()

    #expect(!created)
    #expect(repository.createCallCount == 0)
  }

  @Test(.tags(.tasks))
  func applyAndExportDraftRoundTrip() {
    let viewModel = CreateTaskViewModel(repository: MockTaskRepository())
    let draft = CreateTaskDraft(
      title: "Draft",
      description: "Desc",
      milestones: [MilestoneDraft(title: "M1")]
    )
    viewModel.applyDraft(draft)
    let exported = viewModel.exportDraft()
    #expect(exported.title == "Draft")
    #expect(exported.milestones.count == 1)
  }

  @Test(.tags(.tasks))
  func buildTaskMapsMilestones() {
    let viewModel = CreateTaskViewModel(repository: MockTaskRepository())
    viewModel.title = "Task"
    viewModel.milestones = [
      MilestoneDraft(title: "One"),
      MilestoneDraft(title: "  ")
    ]
    let task = viewModel.buildTask()
    #expect(task.milestones.count == 1)
    #expect(task.milestones.first?.title == "One")
  }
}
