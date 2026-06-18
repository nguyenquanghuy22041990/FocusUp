//
//  DashboardStateHeader.swift
//  FocusUp
//

import SwiftUI

struct DashboardStateHeader: View {
  let snapshot: DashboardSnapshot

  var body: some View {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
      AppTextStyles.screenTitle(snapshot.greetingTitle)
      AppTextStyles.screenSubtitle(snapshot.greetingSubtitle)

      if let hint = snapshot.continuity.restorationHint {
        Text(hint)
          .appFont(.callout)
          .foregroundStyle(AppColors.focus)
          .appMultilineText()
          .accessibilityLabel(hint)
      }
    }
    .accessibilityElement(children: .combine)
    .focusStateTransition(id: snapshot.mood)
  }
}
