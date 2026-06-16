//
//  MilestoneDraftRow.swift
//  FocusUp
//

import SwiftUI

struct MilestoneDraftRow: View {
  @Binding var milestone: MilestoneDraft
  let onRemove: () -> Void

  var body: some View {
    HStack(spacing: AppSpacing.sm) {
      TextField("Milestone title", text: $milestone.title)
        .appFont(.body)
        .padding(AppSpacing.sm)
        .frame(minHeight: AppSpacing.minimumTouchTarget)
        .background(AppColors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.sm, style: .continuous))
        .accessibilityLabel("Milestone title")

      Button(action: onRemove) {
        Image(systemName: "minus.circle.fill")
          .foregroundStyle(AppColors.error)
          .frame(minWidth: AppSpacing.minimumTouchTarget, minHeight: AppSpacing.minimumTouchTarget)
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Remove milestone")
    }
  }
}
