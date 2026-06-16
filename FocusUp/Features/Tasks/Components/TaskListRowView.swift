//
//  TaskListRowView.swift
//  FocusUp
//

import SwiftUI

struct TaskListRowView: View {
  let row: TaskRowModel

  var body: some View {
    TaskCardContainer(title: row.title, isCompleted: row.isCompleted) {
      VStack(alignment: .leading, spacing: AppSpacing.xxs) {
        if !row.subtitle.isEmpty {
          Text(row.subtitle)
            .appFont(.callout)
            .appMultilineText()
            .foregroundStyle(AppColors.secondaryText)
        }

        HStack(spacing: AppSpacing.sm) {
          Text(row.task.priority.title)
            .appFont(.caption)
            .foregroundStyle(AppColors.focus)

          Text(row.task.status.title)
            .appFont(.caption)
            .foregroundStyle(AppColors.secondaryText)
        }

        if let milestoneSummary = row.milestoneSummary {
          Text(milestoneSummary)
            .appFont(.caption)
            .foregroundStyle(AppColors.secondaryText)
        }

        ProgressView(value: row.progress)
          .tint(AppColors.focus)
          .accessibilityLabel("Progress")
          .accessibilityValue("\(Int(row.progress * 100)) percent")
      }
    }
  }
}
