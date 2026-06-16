//
//  ReadableContentView.swift
//  FocusUp
//

import SwiftUI

/// Design-system alias for readable-width content wrapping.
struct ReadableContentView<Content: View>: View {
  var maxWidth: CGFloat = ReadableContentMetrics.maxContentWidth
  var alignment: Alignment = .center
  @ViewBuilder var content: () -> Content

  var body: some View {
    ReadableContentContainer(maxWidth: maxWidth, alignment: alignment, content: content)
  }
}
