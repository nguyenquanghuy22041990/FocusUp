//
//  DashboardPreviewData.swift
//  FocusUp
//

import Foundation

#if DEBUG
enum DashboardPreviewData {
  static var populated: DashboardSnapshot {
    DashboardStateAggregator.buildSnapshot(
      statistics: StatisticsPreviewData.populated,
      tasks: PreviewSampleData.sampleTasks,
      activeFocus: nil,
      activeRest: false
    )
  }

  static var activeFocus: DashboardSnapshot {
    var snapshot = populated
    snapshot.mood = .activeFocus
    snapshot.greetingTitle = "Focus in progress"
    snapshot.greetingSubtitle = "Pick up where you left off—no rush."
    snapshot.continuity = DashboardContinuityState(
      hasActiveFocus: true,
      hasActiveRest: false,
      canResumeFocus: false,
      restorationHint: "Your focus session is active across scenes."
    )
    return snapshot
  }

  static var overdueTasks: DashboardSnapshot {
    let overdue = Task(
      title: "Submit report",
      deadline: Calendar.current.date(byAdding: .day, value: -1, to: .now),
      priority: .high,
      status: .inProgress
    )
    return DashboardStateAggregator.buildSnapshot(
      statistics: StatisticsPreviewData.populated,
      tasks: [overdue] + PreviewSampleData.sampleTasks,
      activeFocus: nil,
      activeRest: false
    )
  }

  static var completedDay: DashboardSnapshot {
    DashboardStateAggregator.buildSnapshot(
      statistics: StatisticsPreviewData.populated,
      tasks: PreviewSampleData.sampleTasks.map {
        var task = $0
        task.status = .completed
        return task
      },
      activeFocus: nil,
      activeRest: false
    )
  }

  static var recovery: DashboardSnapshot {
    var snapshot = DashboardStateAggregator.buildSnapshot(
      statistics: .empty,
      tasks: PreviewSampleData.sampleTasks,
      activeFocus: nil,
      activeRest: false,
      now: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: .now) ?? .now
    )
    snapshot.mood = .recovery
    return snapshot
  }

  static var empty: DashboardSnapshot {
    .empty
  }
}
#endif
