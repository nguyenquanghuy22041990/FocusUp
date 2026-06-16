//
//  TaskListFilterBar.swift
//  FocusUp
//

import SwiftUI

struct TaskListFilterBar: View {
  let selected: TasksRoute
  let onSelect: (TasksRoute) -> Void

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: AppSpacing.sm) {
        ForEach(TasksRoute.filterCases, id: \.id) { route in
          Button {
            onSelect(route)
          } label: {
            Text(route.title)
              .appFont(.callout)
              .padding(.horizontal, AppSpacing.md)
              .padding(.vertical, AppSpacing.xs)
              .frame(minHeight: AppSpacing.minimumTouchTarget)
              .background(selected == route ? AppColors.focus : AppColors.surface)
              .foregroundStyle(selected == route ? AppColors.onFocus : AppColors.primaryText)
              .clipShape(Capsule())
          }
          .buttonStyle(.plain)
          .accessibilityLabel(route.accessibilityLabel)
          .accessibilityAddTraits(selected == route ? .isSelected : [])
        }
      }
    }
  }
}
