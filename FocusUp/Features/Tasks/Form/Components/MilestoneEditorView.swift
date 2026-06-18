//
//  MilestoneEditorView.swift
//  FocusUp
//

import SwiftUI

struct MilestoneEditorView: View {
  @Binding var milestones: [MilestoneDraft]
  var errorMessage: String?

  var body: some View {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
      ForEach($milestones) { $milestone in
        MilestoneDraftRow(milestone: $milestone) {
          remove(milestone.id)
        }
      }

      SecondaryButton(title: "Add Milestone") {
        milestones.append(MilestoneDraft())
      }

      if let errorMessage {
        Text(errorMessage)
          .appFont(.caption)
          .foregroundStyle(AppColors.error)
          .accessibilityLabel("Milestone error: \(errorMessage)")
      }
    }
  }

  private func remove(_ id: UUID) {
    milestones.removeAll { $0.id == id }
  }
}
