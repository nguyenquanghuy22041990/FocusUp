//
//  FocusDistributionCard.swift
//  FocusUp
//

import Charts
import SwiftUI

struct FocusDistributionCard: View {
  let buckets: [FocusDistributionBucket]


  var body: some View {
    AppCard {
      VStack(alignment: .leading, spacing: AppSpacing.md) {
        Text("Focus by day")
          .appFont(.headline)
          .accessibilityAddTraits(.isHeader)

        if buckets.isEmpty {
          Text("Distribution appears after you complete sessions on different days.")
            .appFont(.caption)
            .foregroundStyle(AppColors.secondaryText)
        } else {
          Chart(buckets) { bucket in
            BarMark(
              x: .value("Day", bucket.label),
              y: .value("Share", bucket.proportion * 100)
            )
            .foregroundStyle(AppColors.rest.gradient)
            .cornerRadius(CalmChartStyle.barCornerRadius)
          }
          .frame(minHeight: 120)
          .chartYAxis(.hidden)
          .focusMotionAnimation(buckets, style: .progress)
          .accessibilityHidden(true)

          Text(distributionSummary)
            .appFont(.caption)
            .foregroundStyle(AppColors.secondaryText)
        }
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(distributionSummary)
  }

  private var distributionSummary: String {
    guard let top = buckets.first else {
      return "No focus distribution yet."
    }
    let percent = Int((top.proportion * 100).rounded())
    return "Most focus on \(top.label), about \(percent) percent of your time."
  }
}
