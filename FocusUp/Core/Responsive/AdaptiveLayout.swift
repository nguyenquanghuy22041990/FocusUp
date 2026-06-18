//
//  AdaptiveLayout.swift
//  FocusUp
//

import SwiftUI

/// Stacks content vertically on compact width and horizontally on regular width.
struct AdaptiveStack<Content: View>: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  var alignment: HorizontalAlignment = .center
  var verticalAlignment: VerticalAlignment = .center
  var spacing: CGFloat?
  @ViewBuilder var content: () -> Content

  var body: some View {
    let layout: AnyLayout = horizontalSizeClass == .regular
      ? AnyLayout(HStackLayout(alignment: verticalAlignment, spacing: spacing))
      : AnyLayout(VStackLayout(alignment: alignment, spacing: spacing))

    layout {
      content()
    }
  }
}

/// Picks the first child that fits the available width.
struct AdaptiveContent<Primary: View, Fallback: View>: View {
  @ViewBuilder var primary: () -> Primary
  @ViewBuilder var fallback: () -> Fallback

  var body: some View {
    ViewThatFits {
      primary()
      fallback()
    }
  }
}
