//
//  TaskMilestoneDetailRow.swift
//  FocusUp
//

import SwiftUI

struct TaskMilestoneDetailRow: View {
  let milestone: TaskMilestone
  let onToggle: () -> Void
  let onRemove: () -> Void

  @Environment(\.hapticFeedback) private var hapticFeedback
  @Environment(\.focusMotionReduced) private var motionReduced

  var body: some View {
    HStack(spacing: AppSpacing.md) {
      Button(action: toggleMilestone) {
        milestoneIcon
          .frame(minWidth: AppSpacing.minimumTouchTarget, minHeight: AppSpacing.minimumTouchTarget)
      }
      .buttonStyle(.plain)
      .accessibilityLabel(milestone.isCompleted ? "Completed, \(milestone.title)" : "Mark \(milestone.title) complete")

      Text(milestone.title)
        .appFont(.body)
        .strikethrough(milestone.isCompleted, color: AppColors.secondaryText)
        .foregroundStyle(milestone.isCompleted ? AppColors.secondaryText : AppColors.primaryText)
        .frame(maxWidth: .infinity, alignment: .leading)

      Button(action: onRemove) {
        Image(systemName: "trash")
          .foregroundStyle(AppColors.error)
          .frame(minWidth: AppSpacing.minimumTouchTarget, minHeight: AppSpacing.minimumTouchTarget)
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Remove \(milestone.title)")
    }
    .focusMotionAnimation(milestone.isCompleted, style: .softFade)
  }

  @ViewBuilder
  private var milestoneIcon: some View {
    let image = Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
      .font(.title3)
      .foregroundStyle(milestone.isCompleted ? AppColors.success : AppColors.secondaryText)

    if motionReduced {
      image
    } else {
      image.symbolEffect(.bounce, value: milestone.isCompleted)
    }
  }

  private func toggleMilestone() {
    if !milestone.isCompleted {
      hapticFeedback.taskCompleted()
    } else {
      hapticFeedback.selectionChanged()
    }
    onToggle()
  }
}
