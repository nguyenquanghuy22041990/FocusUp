//
//  TaskProgressTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

struct TaskProgressTests {
  @Test(.tags(.tasks))
  func completedTaskHasFullProgress() {
    let task = Task(title: "Done", status: .completed)
    #expect(task.progress == 1)
  }

  @Test(.tags(.tasks))
  func milestoneRatioCalculatesCorrectly() {
    let task = Task(
      title: "Milestones",
      milestones: [
        TaskMilestone(title: "A", isCompleted: true),
        TaskMilestone(title: "B", isCompleted: false)
      ]
    )
    #expect(task.milestoneCompletionRatio == 0.5)
    #expect(task.progress == 0.5)
  }

  @Test(.tags(.tasks))
  func inProgressWithoutMilestonesUsesHalfProgress() {
    let task = Task(title: "Working", status: .inProgress)
    #expect(task.progress == 0.5)
  }
}
