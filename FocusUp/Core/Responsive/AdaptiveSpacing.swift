//
//  AdaptiveSpacing.swift
//  FocusUp
//

import SwiftUI

enum AdaptiveSpacing {
  static func screenPadding(horizontalSizeClass: UserInterfaceSizeClass?) -> CGFloat {
    horizontalSizeClass == .regular ? AppSpacing.xl : AppSpacing.lg
  }

  static func sectionSpacing(horizontalSizeClass: UserInterfaceSizeClass?) -> CGFloat {
    horizontalSizeClass == .regular ? AppSpacing.xl : AppSpacing.lg
  }

  static func itemSpacing(horizontalSizeClass: UserInterfaceSizeClass?) -> CGFloat {
    horizontalSizeClass == .regular ? AppSpacing.md : AppSpacing.sm
  }
}

struct AdaptiveScreenPadding: ViewModifier {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  func body(content: Content) -> some View {
    content.padding(AdaptiveSpacing.screenPadding(horizontalSizeClass: horizontalSizeClass))
  }
}

extension View {
  func adaptiveScreenPadding() -> some View {
    modifier(AdaptiveScreenPadding())
  }
}
