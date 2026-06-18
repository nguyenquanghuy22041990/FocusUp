//
//  ResponsiveModifiers.swift
//  FocusUp
//

import SwiftUI

extension View {
  func appCardSurface() -> some View {
    padding(AppSpacing.lg)
      .background(AppColors.surface)
      .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous))
  }

  func adaptiveContentPadding() -> some View {
    modifier(AdaptiveContentPaddingModifier())
  }
}

private struct AdaptiveContentPaddingModifier: ViewModifier {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  func body(content: Content) -> some View {
    content.padding(
      AppSpacingScale.scaled(
        AppSpacing.lg,
        horizontalSizeClass: horizontalSizeClass,
        dynamicTypeSize: dynamicTypeSize
      )
    )
  }
}
