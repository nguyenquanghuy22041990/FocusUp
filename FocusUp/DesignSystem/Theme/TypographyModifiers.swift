//
//  TypographyModifiers.swift
//  FocusUp
//

import SwiftUI

enum AppTextRole {
  case largeTitle
  case title
  case headline
  case body
  case callout
  case caption
}

extension View {
  func appFont(_ role: AppTextRole) -> some View {
    modifier(AppFontModifier(role: role))
  }

  func appMultilineText() -> some View {
    fixedSize(horizontal: false, vertical: true)
      .lineLimit(nil)
      .minimumScaleFactor(0.85)
  }
}

private struct AppFontModifier: ViewModifier {
  let role: AppTextRole

  func body(content: Content) -> some View {
    content
      .font(font)
      .foregroundStyle(foreground)
  }

  private var font: Font {
    switch role {
    case .largeTitle: AppTypography.largeTitle()
    case .title: AppTypography.title()
    case .headline: AppTypography.headline()
    case .body: AppTypography.body()
    case .callout: AppTypography.callout()
    case .caption: AppTypography.caption()
    }
  }

  private var foreground: Color {
    switch role {
    case .caption: AppColors.secondaryText
    default: AppColors.primaryText
    }
  }
}
