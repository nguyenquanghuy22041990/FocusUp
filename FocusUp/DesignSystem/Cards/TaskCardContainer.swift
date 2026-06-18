//
//  TaskCardContainer.swift
//  FocusUp
//

import SwiftUI

struct TaskCardContainer<Content: View>: View {
  let title: String
  var isCompleted: Bool = false
  @ViewBuilder var content: () -> Content

  var body: some View {
    AppCard(padding: AppSpacing.md) {
      HStack(alignment: .top, spacing: AppSpacing.md) {
        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
          .font(.title3)
          .foregroundStyle(isCompleted ? AppColors.success : AppColors.secondaryText)
          .frame(minWidth: AppSpacing.minimumTouchTarget, minHeight: AppSpacing.minimumTouchTarget)
          .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: AppSpacing.xs) {
          Text(title)
            .appFont(.headline)
            .strikethrough(isCompleted, color: AppColors.secondaryText)
            .foregroundStyle(isCompleted ? AppColors.secondaryText : AppColors.primaryText)

          content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(isCompleted ? "Completed, \(title)" : title)
  }
}
