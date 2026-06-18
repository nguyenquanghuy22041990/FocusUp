//
//  TaskListEmptyStateView.swift
//  FocusUp
//

import SwiftUI

struct TaskListEmptyStateView: View {
  let filter: TasksRoute

  var body: some View {
    AppCard {
      VStack(alignment: .leading, spacing: AppSpacing.sm) {
        Label("No tasks yet", systemImage: "tray")
          .appFont(.headline)
          .foregroundStyle(AppColors.primaryText)
          .accessibilityAddTraits(.isHeader)

        Text(emptyMessage)
          .appFont(.body)
          .appMultilineText()
          .foregroundStyle(AppColors.secondaryText)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("No tasks. \(emptyMessage)")
  }

  private var emptyMessage: String {
    switch filter {
    case .today:
      "You're clear for today. New tasks will appear here."
    case .upcoming:
      "No upcoming tasks. Plan ahead when you're ready."
    case .completed:
      "No completed tasks yet."
    case .create, .edit, .detail:
      "No tasks to show."
    }
  }
}
