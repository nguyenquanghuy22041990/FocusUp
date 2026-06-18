//
//  TaskDetailMetadataRow.swift
//  FocusUp
//

import SwiftUI

struct TaskDetailMetadataRow: View {
  let label: String
  let value: String
  var isEmpty: Bool = false

  var body: some View {
    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
      Text(label)
        .appFont(.caption)
        .foregroundStyle(AppColors.secondaryText)
      Text(isEmpty ? "—" : value)
        .appFont(.body)
        .appMultilineText()
        .foregroundStyle(isEmpty ? AppColors.secondaryText : AppColors.primaryText)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(label), \(isEmpty ? "empty" : value)")
  }
}
