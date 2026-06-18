//
//  ExpandedView.swift
//  FocusTimerWidget
//

import SwiftUI
import WidgetKit

struct ExpandedView: View {
  let context: ActivityViewContext<FocusSessionAttributes>

  private var tint: Color {
    SessionStyle.accentColor(for: context.attributes.sessionType)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(context.attributes.sessionType.displayName)
          .font(.caption.weight(.semibold))
          .foregroundStyle(tint)
        Spacer()
        Text(SessionStyle.stateLabel(context.state.sessionState))
          .font(.caption2)
          .foregroundStyle(.secondary)
      }

      Text(context.attributes.sessionTitle)
        .font(.headline)
        .lineLimit(1)

      RemainingDetailText(
        endDate: context.state.endDate,
        pausedRemainingSeconds: context.state.pausedRemainingSeconds
      )

      TimerProgressView(progress: liveProgress, tint: tint)

      Text(context.state.motivationalMessage)
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }
    .padding(.horizontal, 4)
  }

  private var liveProgress: Double {
    if context.state.sessionState == .paused {
      return context.state.progress
    }
    guard let endDate = context.state.endDate else { return context.state.progress }
    let total = Double(context.attributes.totalDurationSeconds)
    guard total > 0 else { return 0 }
    let remaining = max(0, endDate.timeIntervalSinceNow)
    return min(1, max(0, 1 - remaining / total))
  }
}
