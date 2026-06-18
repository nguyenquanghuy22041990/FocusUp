//
//  DashboardErrorView.swift
//  FocusUp
//

import SwiftUI

struct DashboardErrorView: View {
  let message: String
  let onRetry: () -> Void

  var body: some View {
    AppCard {
      VStack(alignment: .leading, spacing: AppSpacing.md) {
        Label("Couldn't refresh", systemImage: "exclamationmark.triangle")
          .appFont(.headline)
          .foregroundStyle(AppColors.warning)

        Text(message)
          .appFont(.callout)
          .foregroundStyle(AppColors.secondaryText)
          .appMultilineText()

        SecondaryButton(title: "Try again", action: onRetry)
          .accessibilityHint("Retries loading dashboard data")
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Couldn't refresh dashboard. \(message)")
  }
}
