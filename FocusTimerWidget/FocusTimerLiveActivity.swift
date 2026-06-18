//
//  FocusTimerLiveActivity.swift
//  FocusTimerWidget
//

import ActivityKit
import SwiftUI
import WidgetKit

struct FocusTimerLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: FocusSessionAttributes.self) { context in
      LockScreenView(context: context)
        .activityBackgroundTint(
          SessionStyle.accentColor(for: context.attributes.sessionType).opacity(0.15)
        )
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          CompactLeadingView(sessionType: context.attributes.sessionType)
        }
        DynamicIslandExpandedRegion(.trailing) {
          CountdownText(
            endDate: context.state.endDate,
            pausedRemainingSeconds: context.state.pausedRemainingSeconds,
            font: .title3.monospacedDigit().weight(.semibold)
          )
        }
        DynamicIslandExpandedRegion(.center) {
          Text(context.attributes.sessionTitle)
            .font(.caption)
            .lineLimit(1)
        }
        DynamicIslandExpandedRegion(.bottom) {
          ExpandedView(context: context)
        }
      } compactLeading: {
        CompactLeadingView(sessionType: context.attributes.sessionType)
      } compactTrailing: {
        CompactTrailingView(context: context)
      } minimal: {
        MinimalView(context: context)
      }
    }
  }
}
