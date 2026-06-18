//
//  TaskFormSection.swift
//  FocusUp
//

import SwiftUI

struct TaskFormSection<Content: View>: View {
  let title: String
  var footer: String?
  @ViewBuilder var content: () -> Content

  var body: some View {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
      Text(title)
        .appFont(.headline)
        .foregroundStyle(AppColors.primaryText)
        .accessibilityAddTraits(.isHeader)

      AppCard(padding: AppSpacing.md) {
        content()
      }

      if let footer {
        Text(footer)
          .appFont(.caption)
          .foregroundStyle(AppColors.secondaryText)
          .appMultilineText()
      }
    }
    .accessibilityElement(children: .contain)
  }
}
