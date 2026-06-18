//
//  TaskFormTextFieldRow.swift
//  FocusUp
//

import SwiftUI

struct TaskFormTextFieldRow: View {
  let label: String
  @Binding var text: String
  var errorMessage: String?
  var isRequired: Bool = false

  var body: some View {
    VStack(alignment: .leading, spacing: AppSpacing.xs) {
      Text(label + (isRequired ? " *" : ""))
        .appFont(.callout)
        .foregroundStyle(AppColors.secondaryText)

      TextField(label, text: $text)
        .textFieldStyle(.plain)
        .appFont(.body)
        .padding(AppSpacing.sm)
        .frame(minHeight: AppSpacing.minimumTouchTarget)
        .background(AppColors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.sm, style: .continuous))
        .accessibilityLabel(accessibilityLabel)

      if let errorMessage {
        Text(errorMessage)
          .appFont(.caption)
          .foregroundStyle(AppColors.error)
          .focusValidationTransition(message: errorMessage)
          .accessibilityLabel("Error: \(errorMessage)")
      }
    }
  }

  private var accessibilityLabel: String {
    if let errorMessage {
      return "\(label). \(errorMessage)"
    }
    return label
  }
}
