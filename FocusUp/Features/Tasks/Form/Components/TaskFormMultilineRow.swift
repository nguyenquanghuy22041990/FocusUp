//
//  TaskFormMultilineRow.swift
//  FocusUp
//

import SwiftUI

struct TaskFormMultilineRow: View {
  let label: String
  @Binding var text: String
  var errorMessage: String?
  var lineLimit: ClosedRange<Int> = 3...8

  var body: some View {
    VStack(alignment: .leading, spacing: AppSpacing.xs) {
      Text(label)
        .appFont(.callout)
        .foregroundStyle(AppColors.secondaryText)

      TextField(label, text: $text, axis: .vertical)
        .lineLimit(lineLimit)
        .textFieldStyle(.plain)
        .appFont(.body)
        .appMultilineText()
        .padding(AppSpacing.sm)
        .frame(minHeight: AppSpacing.minimumTouchTarget * 2, alignment: .topLeading)
        .background(AppColors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.sm, style: .continuous))
        .accessibilityLabel(label)

      if let errorMessage {
        Text(errorMessage)
          .appFont(.caption)
          .foregroundStyle(AppColors.error)
          .focusValidationTransition(message: errorMessage)
      }
    }
  }
}
