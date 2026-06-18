//
//  TaskDetailProgressSection.swift
//  FocusUp
//

import SwiftUI

struct TaskDetailProgressSection: View {
  let progress: Double
  let completedCount: Int
  let totalMilestones: Int
  let isCompleted: Bool

  var body: some View {
    TaskDetailSection(title: "Progress") {
      AdaptiveStack(alignment: .leading, spacing: AppSpacing.lg) {
        ProgressRingView(
          progress: progress,
          tint: isCompleted ? AppColors.success : AppColors.focus
        )

        VStack(alignment: .leading, spacing: AppSpacing.sm) {
          Text("\(Int(progress * 100))% complete")
            .appFont(.title)
            .foregroundStyle(AppColors.primaryText)
            .accessibilityLabel("Progress \(Int(progress * 100)) percent")

          if totalMilestones > 0 {
            Text("\(completedCount) of \(totalMilestones) milestones completed")
              .appFont(.body)
              .foregroundStyle(AppColors.secondaryText)
          } else {
            Text(isCompleted ? "Task completed" : "No milestones yet")
              .appFont(.body)
              .foregroundStyle(AppColors.secondaryText)
          }

          ProgressView(value: progress)
            .tint(isCompleted ? AppColors.success : AppColors.focus)
            .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}
