//
//  TaskFormPriorityPicker.swift
//  FocusUp
//

import SwiftUI

struct TaskFormPriorityPicker: View {
  @Binding var priority: TaskPriority

  var body: some View {
    VStack(alignment: .leading, spacing: AppSpacing.xs) {
      Text("Priority")
        .appFont(.callout)
        .foregroundStyle(AppColors.secondaryText)

      Picker("Priority", selection: $priority) {
        ForEach(TaskPriority.allCases) { level in
          Text(level.title).tag(level)
        }
      }
      .pickerStyle(.segmented)
      .accessibilityLabel("Task priority")
    }
  }
}
