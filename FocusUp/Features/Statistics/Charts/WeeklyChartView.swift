//
//  WeeklyChartView.swift
//  FocusUp
//

import Charts
import SwiftUI

struct WeeklyChartView: View {
  let points: [ChartDayPoint]
  let accessibilitySummary: String


  var body: some View {
    CalmChartContainer(
      title: "Weekly focus",
      accessibilitySummary: accessibilitySummary
    ) {
      if points.allSatisfy({ $0.minutes == 0 }) {
        emptyChartPlaceholder
      } else {
        Chart(points) { point in
          BarMark(
            x: .value("Day", point.label),
            y: .value("Minutes", point.minutes)
          )
          .foregroundStyle(AppColors.focus.gradient)
          .cornerRadius(CalmChartStyle.barCornerRadius)
        }
        .chartYAxis {
          AxisMarks(position: .leading) { _ in
            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
              .foregroundStyle(AppColors.separator.opacity(CalmChartStyle.gridOpacity))
            AxisValueLabel()
              .foregroundStyle(CalmChartStyle.axisLabelColor)
          }
        }
        .chartXAxis {
          AxisMarks { _ in
            AxisValueLabel()
              .foregroundStyle(CalmChartStyle.axisLabelColor)
          }
        }
        .focusMotionAnimation(points, style: .progress)
      }
    }
  }

  private var emptyChartPlaceholder: some View {
    VStack(spacing: AppSpacing.sm) {
      Image(systemName: "chart.bar")
        .font(.title2)
        .foregroundStyle(AppColors.secondaryText)
      Text("No focus data this week yet")
        .appFont(.caption)
        .foregroundStyle(AppColors.secondaryText)
    }
    .frame(maxWidth: .infinity, minHeight: CalmChartStyle.chartHeight)
  }
}
