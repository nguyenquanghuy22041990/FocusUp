//
//  DashboardPrioritySection.swift
//  FocusUp
//

import SwiftUI

struct DashboardPrioritySection: View {
  let priorities: [DashboardPriorityRecommendation]
  let onSelectTask: (UUID) -> Void

  var body: some View {
    StatisticsSection(
      title: "Suggested next steps",
      subtitle: priorities.isEmpty ? "You're clear for now—start a focus session or add a task." : nil
    ) {
      if priorities.isEmpty {
        AppCard {
          Text("No urgent tasks right now. A short focus block or a new task can set a gentle direction.")
            .appFont(.body)
            .foregroundStyle(AppColors.secondaryText)
            .appMultilineText()
        }
      } else {
        VStack(spacing: AppSpacing.sm) {
          ForEach(priorities) { item in
            priorityRow(item)
          }
        }
      }
    }
  }

  private func priorityRow(_ item: DashboardPriorityRecommendation) -> some View {
    Button {
      onSelectTask(item.taskID)
    } label: {
      AppCard(padding: AppSpacing.md) {
        HStack(alignment: .top, spacing: AppSpacing.md) {
          Image(systemName: item.hasIncompleteMilestones ? "list.bullet.circle" : "circle")
            .foregroundStyle(AppColors.focus)
            .frame(minWidth: AppSpacing.minimumTouchTarget, minHeight: AppSpacing.minimumTouchTarget)
            .accessibilityHidden(true)

          VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(item.title)
              .appFont(.headline)
              .foregroundStyle(AppColors.primaryText)
              .multilineTextAlignment(.leading)
            Text(item.reason)
              .appFont(.caption)
              .foregroundStyle(AppColors.secondaryText)
              .multilineTextAlignment(.leading)
          }
          .frame(maxWidth: .infinity, alignment: .leading)

          Image(systemName: "chevron.right")
            .foregroundStyle(AppColors.secondaryText)
            .accessibilityHidden(true)
        }
      }
    }
    .buttonStyle(.plain)
    .accessibilityLabel("\(item.title). \(item.reason). Open task.")
    .focusMotionAnimation(item.urgencyScore, style: .softFade)
  }
}
