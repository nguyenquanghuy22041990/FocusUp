//
//  MinimalView.swift
//  FocusTimerWidget
//

import SwiftUI
import WidgetKit

struct MinimalView: View {
  let context: ActivityViewContext<FocusSessionAttributes>

  var body: some View {
    CountdownText(
      endDate: context.state.endDate,
      pausedRemainingSeconds: context.state.pausedRemainingSeconds,
      font: .caption2.monospacedDigit().weight(.semibold),
      minimal: true
    )
  }
}
