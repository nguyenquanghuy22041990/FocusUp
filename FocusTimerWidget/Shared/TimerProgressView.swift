//
//  TimerProgressView.swift
//  FocusTimerWidget
//

import SwiftUI

struct TimerProgressView: View {
  let progress: Double
  let tint: Color

  var body: some View {
    GeometryReader { proxy in
      ZStack(alignment: .leading) {
        Capsule()
          .fill(tint.opacity(0.25))
        Capsule()
          .fill(tint)
          .frame(width: max(4, proxy.size.width * min(1, max(0, progress))))
      }
    }
    .frame(height: 6)
  }
}
