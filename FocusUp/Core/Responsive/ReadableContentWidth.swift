//
//  ReadableContentWidth.swift
//  FocusUp
//

import SwiftUI

enum ReadableContentMetrics {
  /// Maximum readable line width for primary content on regular layouts.
  static let maxContentWidth: CGFloat = 680
  /// Slightly wider cap for dashboard-style grids.
  static let maxWideContentWidth: CGFloat = 960
}

struct ReadableContentContainer<Content: View>: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  let maxWidth: CGFloat
  let alignment: Alignment
  @ViewBuilder let content: () -> Content

  init(
    maxWidth: CGFloat = ReadableContentMetrics.maxContentWidth,
    alignment: Alignment = .center,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.maxWidth = maxWidth
    self.alignment = alignment
    self.content = content
  }

  var body: some View {
    content()
      .frame(maxWidth: horizontalSizeClass == .regular ? maxWidth : nil)
      .frame(maxWidth: .infinity, alignment: alignment)
  }
}

extension View {
  func readableContentWidth(
    _ maxWidth: CGFloat = ReadableContentMetrics.maxContentWidth,
    alignment: Alignment = .center
  ) -> some View {
    ReadableContentContainer(maxWidth: maxWidth, alignment: alignment) {
      self
    }
  }
}
