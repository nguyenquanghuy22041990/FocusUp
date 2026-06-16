//
//  LockScreenView.swift
//  FocusTimerWidget
//

import SwiftUI
import WidgetKit

struct LockScreenView: View {
  let context: ActivityViewContext<FocusSessionAttributes>

  private var tint: Color {
    SessionStyle.accentColor(for: context.attributes.sessionType)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(alignment: .firstTextBaseline) {
        VStack(alignment: .leading, spacing: 4) {
          Text(context.attributes.sessionType.displayName)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint)
          Text(context.attributes.sessionTitle)
            .font(.headline)
            .lineLimit(2)
        }
        Spacer(minLength: 8)
        Text(SessionStyle.stateLabel(context.state.sessionState))
          .font(.caption2.weight(.medium))
          .foregroundStyle(.secondary)
      }

      Group {
        if let endDate = context.state.endDate {
          Text(timerInterval: Date()...endDate, countsDown: true)
        } else if let paused = context.state.pausedRemainingSeconds {
          Text(WidgetTimerFormatting.pausedClock(seconds: paused))
        } else {
          Text("Done")
        }
      }
      .font(.system(size: 40, weight: .semibold, design: .rounded))
      .monospacedDigit()
      .contentTransition(.numericText(countsDown: true))
      .minimumScaleFactor(0.7)
      .lineLimit(1)

      TimerProgressView(progress: lockProgress, tint: tint)

      HStack {
        Label {
          Text(context.attributes.startDate, style: .time)
        } icon: {
          Image(systemName: "play.fill")
        }
        Spacer()
        Label {
          Text(context.attributes.plannedEndDate, style: .time)
        } icon: {
          Image(systemName: "flag.checkered")
        }
      }
      .font(.caption2)
      .foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }

  private var lockProgress: Double {
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
