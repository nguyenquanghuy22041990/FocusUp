//
//  AppCard.swift
//  FocusUp
//

import SwiftUI

struct AppCard<Content: View>: View {
  var padding: CGFloat = AppSpacing.lg
  @ViewBuilder var content: () -> Content

  var body: some View {
    content()
      .padding(padding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(AppColors.surface)
      .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
          .stroke(AppColors.separator.opacity(0.35), lineWidth: 0.5)
      )
      .focusCardAppearance()
      .accessibilityElement(children: .contain)
  }
}
