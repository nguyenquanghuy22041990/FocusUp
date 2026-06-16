//
//  FocusTaskAssociationPicker.swift
//  FocusUp
//

import SwiftUI

struct FocusTaskAssociationPicker: View {
  let tasks: [Task]
  @Binding var selectedTask: Task?

  private var linkedTaskDisplayTitle: String {
    guard let selectedTask,
          tasks.contains(where: { $0.id == selectedTask.id })
    else {
      return "No task"
    }
    return selectedTask.title
  }

  var body: some View {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
      Text("Link a task")
        .appFont(.headline)
        .foregroundStyle(AppColors.primaryText)

      Menu {
        Button("No task") {
          selectedTask = nil
        }

        if tasks.isEmpty {
          Button("No open tasks") {}
            .disabled(true)
        } else {
          ForEach(tasks) { task in
            Button(task.title) {
              selectedTask = task
            }
          }
        }
      } label: {
        HStack {
          Text(linkedTaskDisplayTitle)
            .appFont(.body)
            .foregroundStyle(AppColors.primaryText)
          Spacer()
          Image(systemName: "chevron.up.chevron.down")
            .foregroundStyle(AppColors.secondaryText)
        }
        .frame(minHeight: AppSpacing.minimumTouchTarget)
        .padding(.horizontal, AppSpacing.md)
        .background(AppColors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonRadius, style: .continuous))
      }
      .accessibilityLabel("Associated task")
      .accessibilityValue(linkedTaskDisplayTitle)
    }
  }
}
