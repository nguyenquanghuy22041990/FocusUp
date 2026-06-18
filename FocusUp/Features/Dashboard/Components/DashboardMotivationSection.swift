//
//  DashboardMotivationSection.swift
//  FocusUp
//

import SwiftUI

struct DashboardMotivationSection: View {
  let title: String
  let bodyText: String

  var body: some View {
    StatisticsSection(title: "Encouragement", subtitle: "Supportive, not stressful") {
      AppCard {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
          Label(title, systemImage: "leaf.fill")
            .appFont(.headline)
            .foregroundStyle(AppColors.rest)
          Text(bodyText)
            .appFont(.body)
            .foregroundStyle(AppColors.secondaryText)
            .appMultilineText()
        }
      }
      .accessibilityElement(children: .combine)
      .accessibilityLabel("\(title). \(bodyText)")
    }
  }
}
