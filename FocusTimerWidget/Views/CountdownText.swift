//
//  CountdownText.swift
//  FocusTimerWidget
//

import SwiftUI

struct CountdownText: View {
  let endDate: Date?
  let pausedRemainingSeconds: Int?
  var font: Font = .caption.monospacedDigit()
  var minimal: Bool = false

  var body: some View {
    Group {
      if let endDate {
        if minimal {
          Text(timerInterval: Date()...endDate, countsDown: true)
            .monospacedDigit()
            .font(font)
            .multilineTextAlignment(.trailing)
            .frame(minWidth: 28)
            .contentTransition(.numericText(countsDown: true))
        } else {
          Text(timerInterval: Date()...endDate, countsDown: true)
            .monospacedDigit()
            .font(font)
            .contentTransition(.numericText(countsDown: true))
        }
      } else if let pausedRemainingSeconds {
        Text(
          minimal
            ? WidgetTimerFormatting.minimalLabel(seconds: pausedRemainingSeconds)
            : WidgetTimerFormatting.pausedClock(seconds: pausedRemainingSeconds)
        )
        .monospacedDigit()
        .font(font)
      } else {
        Text("0:00")
          .monospacedDigit()
          .font(font)
      }
    }
  }
}

struct RemainingDetailText: View {
  let endDate: Date?
  let pausedRemainingSeconds: Int?

  var body: some View {
    if let endDate {
      (
        Text(timerInterval: Date()...endDate, countsDown: true)
        + Text(" remaining")
      )
      .monospacedDigit()
      .font(.subheadline.weight(.medium))
      .contentTransition(.numericText(countsDown: true))
    } else if let pausedRemainingSeconds {
      Text("\(WidgetTimerFormatting.pausedClock(seconds: pausedRemainingSeconds)) remaining")
        .monospacedDigit()
        .font(.subheadline.weight(.medium))
    } else {
      Text("Complete")
        .font(.subheadline.weight(.medium))
    }
  }
}
