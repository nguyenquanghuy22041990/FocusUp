//
//  TaskMilestoneManagementSection.swift
//  FocusUp
//

import SwiftUI

struct TaskMilestoneManagementSection: View {
  let milestones: [TaskMilestone]
  let onToggle: (UUID) -> Void
  let onRemove: (UUID) -> Void
  let onAdd: () -> Void

  var body: some View {
    TaskDetailSection(title: "Milestones") {
      VStack(alignment: .leading, spacing: AppSpacing.sm) {
        if milestones.isEmpty {
          Text("No milestones yet. Add steps to track progress.")
            .appFont(.body)
            .foregroundStyle(AppColors.secondaryText)
            .appMultilineText()
        } else {
          ForEach(milestones) { milestone in
            TaskMilestoneDetailRow(
              milestone: milestone,
              onToggle: { onToggle(milestone.id) },
              onRemove: { onRemove(milestone.id) }
            )
            if milestone.id != milestones.last?.id {
              Divider()
            }
          }
        }

        SecondaryButton(title: "Add Milestone", action: onAdd)
      }
    }
  }
}
