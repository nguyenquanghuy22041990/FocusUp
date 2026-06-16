//
//  FocusTimerStartViewModelTests.swift
//  FocusUp
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct FocusTimerStartViewModelTests {
  private func makeViewModel() throws -> (FocusTimerStartViewModel, FocusSessionManager, MockTaskRepository) {
    let persistence = try PersistenceController(inMemory: true)
    let repository = FocusRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()
    let manager = FocusSessionManager(
      repository: repository,
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    let tasks = MockTaskRepository(tasks: [
      DomainFixtures.task(title: "Write chapter"),
      DomainFixtures.task(title: "Done task", status: .completed)
    ])
    let viewModel = FocusTimerStartViewModel(
      sessionManager: manager,
      taskRepository: tasks
    )
    return (viewModel, manager, tasks)
  }

  @Test(.tags(.focus))
  func presetSelectionUpdatesDuration() async throws {
    let (viewModel, _, _) = try makeViewModel()

    viewModel.selectPreset(.fifteen)
    #expect(viewModel.selectedPreset.durationSeconds == 15 * 60)

    viewModel.selectPreset(.sixty)
    #expect(viewModel.selectedPreset.durationSeconds == 60 * 60)
  }

  @Test(.tags(.focus))
  func loadTasksFiltersCompleted() async throws {
    let (viewModel, _, _) = try makeViewModel()

    await viewModel.loadTasks()

    #expect(viewModel.availableTasks.count == 1)
    #expect(viewModel.availableTasks.first?.title == "Write chapter")
  }

  @Test(.tags(.focus))
  func loadTasksClearsCompletedTaskSelection() async throws {
    let (viewModel, _, tasks) = try makeViewModel()
    guard let completed = tasks.tasks.first(where: { $0.isCompleted }) else {
      Issue.record("Expected a completed task fixture")
      return
    }
    viewModel.selectedTask = completed
    viewModel.customTitle = completed.title

    await viewModel.loadTasks()

    #expect(viewModel.selectedTask == nil)
    #expect(viewModel.customTitle.isEmpty)
    #expect(viewModel.availableTasks.allSatisfy { !$0.isCompleted })
  }

  @Test(.tags(.focus))
  func loadTasksClearsStaleSelectionWhenTaskCompletedInRepository() async throws {
    let (viewModel, _, tasks) = try makeViewModel()
    guard let openIndex = tasks.tasks.firstIndex(where: { !$0.isCompleted }) else {
      Issue.record("Expected an open task fixture")
      return
    }
    let open = tasks.tasks[openIndex]
    viewModel.selectedTask = open
    viewModel.customTitle = open.title

    var completed = open
    completed.status = .completed
    tasks.tasks[openIndex] = completed

    await viewModel.loadTasks()

    #expect(viewModel.selectedTask == nil)
    #expect(viewModel.customTitle.isEmpty)
  }

  @Test(.tags(.focus))
  func customTitleOverridesLinkedTaskOnStart() async throws {
    let (viewModel, manager, tasks) = try makeViewModel()
    await viewModel.loadTasks()
    viewModel.selectTask(tasks.tasks.first)
    viewModel.customTitle = "Deep work block"
    viewModel.selectPreset(.thirty)

    let started = await viewModel.startSession()

    #expect(started)
    #expect(manager.activeSession?.title == "Deep work block")
    #expect(manager.activeSession?.associatedTaskID == tasks.tasks.first?.id)
  }

  @Test(.tags(.focus))
  func startSessionUsesTaskTitleAndNavigates() async throws {
    let (viewModel, manager, tasks) = try makeViewModel()
    await viewModel.loadTasks()
    viewModel.selectTask(tasks.tasks.first)
    viewModel.selectPreset(.thirty)

    let started = await viewModel.startSession()

    #expect(started)
    #expect(manager.activeSession?.title == "Write chapter")
    #expect(manager.activeSession?.plannedDurationSeconds == 30 * 60)
    #expect(manager.activeSession?.associatedTaskID == tasks.tasks.first?.id)
  }
}
