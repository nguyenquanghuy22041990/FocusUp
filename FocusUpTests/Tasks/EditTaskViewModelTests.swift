//
//  EditTaskViewModelTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct EditTaskViewModelTests {
  @Test(.tags(.tasks))
  func loadPopulatesForm() async {
    let task = TaskPreviewData.list[0]
    let repository = MockTaskRepository(tasks: [task])
    let viewModel = EditTaskViewModel(taskID: task.id, repository: repository)

    await viewModel.load()

    #expect(viewModel.title == task.title)
    #expect(viewModel.description == task.notes)
    #expect(viewModel.submissionState == .idle)
  }

  @Test(.tags(.tasks))
  func saveChangesUpdatesRepository() async {
    let task = Task(title: "Original")
    let repository = MockTaskRepository(tasks: [task])
    let viewModel = EditTaskViewModel(taskID: task.id, repository: repository)

    await viewModel.load()
    viewModel.title = "Updated title"

    let saved = await viewModel.saveChanges()

    #expect(saved)
    #expect(repository.tasks.first?.title == "Updated title")
  }

  @Test(.tags(.tasks))
  func persistedDraftAfterLoadDoesNotLeaveLoadingState() async {
    let task = Task(title: "From database")
    let repository = MockTaskRepository(tasks: [task])
    let viewModel = EditTaskViewModel(taskID: task.id, repository: repository)

    EditDraftStore.save(
      EditTaskDraft(
        taskID: task.id,
        form: CreateTaskDraft(
          title: "Stale draft title",
          savedAt: .now.addingTimeInterval(-120)
        )
      )
    )
    viewModel.submissionState = .loading

    await viewModel.load()

    #expect(viewModel.title == "From database")
    #expect(viewModel.submissionState == .idle)

    EditDraftStore.clear(taskID: task.id)
  }

  @Test(.tags(.tasks))
  func saveChangesRemovesDeletedMilestone() async {
    let milestoneToKeep = TaskMilestone(title: "Keep")
    let milestoneToRemove = TaskMilestone(title: "Remove")
    let task = Task(
      title: "Milestones",
      milestones: [milestoneToKeep, milestoneToRemove]
    )
    let repository = MockTaskRepository(tasks: [task])
    let viewModel = EditTaskViewModel(taskID: task.id, repository: repository)

    await viewModel.load()
    viewModel.milestones.removeAll { $0.id == milestoneToRemove.id }

    let saved = await viewModel.saveChanges()

    #expect(saved)
    let updated = repository.tasks.first
    #expect(updated != nil)
    #expect(updated?.milestones.count == 1)
    #expect(updated?.milestones.first?.id == milestoneToKeep.id)
    #expect(updated?.milestones.first?.isCompleted == milestoneToKeep.isCompleted)
  }

  @Test(.tags(.tasks))
  func newerPersistedDraftOverridesLoadedTask() async {
    let task = Task(title: "From database", updatedAt: .now.addingTimeInterval(-120))
    let repository = MockTaskRepository(tasks: [task])
    let viewModel = EditTaskViewModel(taskID: task.id, repository: repository)

    EditDraftStore.save(
      EditTaskDraft(
        taskID: task.id,
        form: CreateTaskDraft(title: "Draft title", savedAt: .now)
      )
    )

    await viewModel.load()

    #expect(viewModel.title == "Draft title")
    EditDraftStore.clear(taskID: task.id)
  }

  @Test(.tags(.tasks))
  func saveChangesAcceptsDeadlineSetOnPreviousDay() async {
    let calendar = Calendar.current
    let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now))!
    let task = Task(title: "Due task", deadline: yesterday)
    let repository = MockTaskRepository(tasks: [task])
    let viewModel = EditTaskViewModel(taskID: task.id, repository: repository)

    await viewModel.load()

    let saved = await viewModel.saveChanges()

    #expect(saved)
    #expect(repository.tasks.first?.deadline == calendar.startOfDay(for: .now))
  }

  @Test(.tags(.tasks))
  func exportDraftIncludesTaskID() {
    let viewModel = EditTaskViewModel(
      taskID: UUID(),
      repository: MockTaskRepository()
    )
    viewModel.title = "Draft"
    let draft = viewModel.exportDraft()
    #expect(draft.taskID == viewModel.taskID)
    #expect(draft.form.title == "Draft")
  }
}
