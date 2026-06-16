//
//  ResponsiveContainer.swift
//  FocusUp
//

import SwiftUI

/// Standard screen shell: safe area, adaptive padding, readable width, themed background.
struct ResponsiveContainer<Content: View>: View {
  let wide: Bool
  @ViewBuilder let content: () -> Content

  init(wide: Bool = false, @ViewBuilder content: @escaping () -> Content) {
    self.wide = wide
    self.content = content
  }

  var body: some View {
    KeyboardDismissibleScrollView {
      ReadableContentContainer(
        maxWidth: wide
          ? ReadableContentMetrics.maxWideContentWidth
          : ReadableContentMetrics.maxContentWidth
      ) {
        content()
          .adaptiveScreenPadding()
      }
    }
    .background(AppColors.background)
  }
}
