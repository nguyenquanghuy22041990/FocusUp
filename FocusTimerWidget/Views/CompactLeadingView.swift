//
//  CompactLeadingView.swift
//  FocusTimerWidget
//

import SwiftUI

struct CompactLeadingView: View {
  let sessionType: SessionLiveActivityType

  var body: some View {
    Text(sessionType.compactIcon)
      .font(.body)
  }
}
