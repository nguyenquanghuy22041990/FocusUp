//
//  TaskPreviewData.swift
//  FocusUp
//

import Foundation

enum TaskPreviewData {
  static var list: [Task] {
    [
      Task(
        title: "Plan weekly focus goals",
        notes: "Outline priorities for the week ahead.",
        priority: .high,
        status: .inProgress,
        milestones: [
          TaskMilestone(title: "Review calendar"),
          TaskMilestone(title: "Pick top 3 goals", isCompleted: true)
        ]
      ),
      Task(
        title: "Write project brief",
        notes: "Universal layout validation on iPhone and iPad.",
        priority: .medium,
        status: .todo
      ),
      Task(
        title: "Review analytics snapshot",
        priority: .low,
        status: .completed,
        milestones: [
          TaskMilestone(title: "Export chart", isCompleted: true),
          TaskMilestone(title: "Share summary", isCompleted: true)
        ]
      )
    ]
  }

  static var empty: [Task] { [] }
}
