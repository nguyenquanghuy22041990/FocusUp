//
//  CalmChartStyle.swift
//  FocusUp
//

import SwiftUI

enum CalmChartStyle {
  static let focusGradient = LinearGradient(
    colors: [AppColors.focus.opacity(0.55), AppColors.focus.opacity(0.15)],
    startPoint: .top,
    endPoint: .bottom
  )

  static let axisLabelColor = AppColors.secondaryText
  static let gridOpacity: Double = 0.2
  static let barCornerRadius: CGFloat = 6
  static let chartHeight: CGFloat = 180
}

struct CalmChartContainer<Chart: View>: View {
  let title: String
  let accessibilitySummary: String
  @ViewBuilder var chart: () -> Chart

  var body: some View {
    StatisticsCard(title: title, summary: accessibilitySummary) {
      chart()
        .frame(maxWidth: .infinity, minHeight: CalmChartStyle.chartHeight)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(title). \(accessibilitySummary)")
  }
}
