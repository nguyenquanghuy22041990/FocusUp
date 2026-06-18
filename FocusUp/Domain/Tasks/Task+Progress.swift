//
//  Task+Progress.swift
//  FocusUp
//

import Foundation

extension Task {
  /// Overall completion progress from `0` to `1`.
  var progress: Double {
    if status.isDone { return 1 }
    guard !milestones.isEmpty else {
      return status == .inProgress ? 0.5 : 0
    }
    return milestoneCompletionRatio
  }

  /// Ratio of completed milestones, or `0` when there are none.
  var milestoneCompletionRatio: Double {
    guard !milestones.isEmpty else { return 0 }
    let completed = milestones.filter(\.isCompleted).count
    return Double(completed) / Double(milestones.count)
  }

  var completedMilestoneCount: Int {
    milestones.filter(\.isCompleted).count
  }
}
