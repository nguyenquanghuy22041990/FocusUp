//
//  CompletionRateChart.swift
//  FocusUp
//

import Charts
import SwiftUI

struct CompletionRateChart: View {
  let completionRate: Double
  let completedCount: Int
  let trackableCount: Int


  private var percentValue: Int {
    Int((min(1, max(0, completionRate)) * 100).rounded())
  }

  var body: some View {
    CalmChartContainer(
      title: "Task completion",
      accessibilitySummary: trackableCount == 0
        ? "No tasks to measure."
        : "\(completedCount) of \(trackableCount) tasks complete. \(percentValue) percent."
    ) {
      Chart {
        BarMark(
          x: .value("Completed", percentValue),
          y: .value("Metric", "Tasks")
        )
        .foregroundStyle(AppColors.success.gradient)
        .cornerRadius(CalmChartStyle.barCornerRadius)
      }
      .chartXScale(domain: 0...100)
      .chartXAxis {
        AxisMarks(values: [0, 50, 100]) { value in
          AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
            .foregroundStyle(AppColors.separator.opacity(CalmChartStyle.gridOpacity))
          AxisValueLabel {
            if let intValue = value.as(Int.self) {
              Text("\(intValue)%")
            }
          }
          .foregroundStyle(CalmChartStyle.axisLabelColor)
        }
      }
      .chartYAxis(.hidden)
      .focusMotionAnimation(percentValue, style: .progress)
    }
  }
}
