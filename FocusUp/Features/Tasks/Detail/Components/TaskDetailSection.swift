//
//  TaskDetailSection.swift
//  FocusUp
//

import SwiftUI

struct TaskDetailSection<Content: View>: View {
  let title: String
  @ViewBuilder var content: () -> Content

  var body: some View {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
      Text(title)
        .appFont(.headline)
        .foregroundStyle(AppColors.primaryText)
        .accessibilityAddTraits(.isHeader)

      AppCard {
        content()
      }
    }
    .accessibilityElement(children: .contain)
  }
}
