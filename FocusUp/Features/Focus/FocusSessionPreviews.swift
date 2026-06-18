//
//  FocusSessionPreviews.swift
//  FocusUp
//

import SwiftUI

private struct FocusSessionPreviewCard: View {
  let session: FocusSession

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(session.title)
        .font(.headline)
      Text(session.accessibilityStatusLabel)
      Text(session.accessibilityElapsedDescription())
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .padding()
  }
}

#Preview("Focus Sessions – iPhone") {
  List(FocusPreviewData.all, id: \.id) { session in
    FocusSessionPreviewCard(session: session)
  }
}

#Preview("Active Session – Dark") {
  FocusSessionPreviewCard(session: FocusPreviewData.active)
    .preferredColorScheme(.dark)
}

#Preview("Paused Session – iPad Landscape", traits: .landscapeLeft) {
  FocusSessionPreviewCard(session: FocusPreviewData.paused)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
