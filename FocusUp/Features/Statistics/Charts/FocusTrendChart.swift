//
//  FocusTrendChart.swift
//  FocusUp
//

import Charts
import SwiftUI

struct FocusTrendChart: View {
  let points: [ChartDayPoint]
  let trend: ProductivityTrend


  var body: some View {
    CalmChartContainer(
      title: "Focus trend",
      accessibilitySummary: StatisticsFormatting.trendAccessibilityLabel(trend) + " " + trend.insight
    ) {
      if points.allSatisfy({ $0.minutes == 0 }) {
        Text("Trend appears after your first sessions.")
          .appFont(.caption)
          .foregroundStyle(AppColors.secondaryText)
          .frame(maxWidth: .infinity, minHeight: CalmChartStyle.chartHeight)
      } else {
        Chart(points) { point in
          AreaMark(
            x: .value("Day", point.label),
            y: .value("Minutes", point.minutes)
          )
          .foregroundStyle(CalmChartStyle.focusGradient)

          LineMark(
            x: .value("Day", point.label),
            y: .value("Minutes", point.minutes)
          )
          .foregroundStyle(AppColors.focus)
          .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
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
}
