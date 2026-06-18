//
//  TaskFormContentView.swift
//  FocusUp
//

import SwiftUI

/// Shared task form fields reused by create and edit flows.
struct TaskFormContentView: View {
  @Binding var title: String
  @Binding var description: String
  @Binding var purpose: String
  @Binding var hobbies: String
  @Binding var deadline: Date?
  @Binding var priority: TaskPriority
  @Binding var milestones: [MilestoneDraft]

  let errorMessage: (CreateTaskField) -> String?

  var body: some View {
    VStack(alignment: .leading, spacing: AppSpacing.xl) {
      TaskFormSection(title: "Basics", footer: "Give your task a clear, actionable title.") {
        VStack(spacing: AppSpacing.md) {
          TaskFormTextFieldRow(
            label: "Title",
            text: $title,
            errorMessage: errorMessage(.title),
            isRequired: true
          )
          TaskFormMultilineRow(
            label: "Description",
            text: $description,
            errorMessage: errorMessage(.description)
          )
        }
      }

      TaskFormSection(title: "Details") {
        VStack(spacing: AppSpacing.md) {
          TaskFormMultilineRow(
            label: "Purpose",
            text: $purpose,
            errorMessage: errorMessage(.purpose),
            lineLimit: 2...4
          )
          TaskFormMultilineRow(
            label: "Hobbies",
            text: $hobbies,
            errorMessage: errorMessage(.hobbies),
            lineLimit: 2...4
          )
          TaskFormDateRow(
            label: "Deadline",
            date: $deadline,
            errorMessage: errorMessage(.deadline)
          )
        }
      }

      TaskFormSection(title: "Milestones", footer: "Break the task into smaller steps.") {
        MilestoneEditorView(
          milestones: $milestones,
          errorMessage: errorMessage(.milestones)
        )
      }

      TaskFormSection(title: "Priority") {
        TaskFormPriorityPicker(priority: $priority)
      }
    }
  }
}
