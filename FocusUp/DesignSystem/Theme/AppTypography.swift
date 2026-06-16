//
//  AppTypography.swift
//  FocusUp
//

import SwiftUI

enum AppTypography {
  static func largeTitle() -> Font {
    .system(.largeTitle, design: .rounded).weight(.bold)
  }

  static func title() -> Font {
    .system(.title2, design: .rounded).weight(.semibold)
  }

  static func headline() -> Font {
    .system(.headline, design: .default).weight(.semibold)
  }

  static func body() -> Font {
    .system(.body, design: .default)
  }

  static func callout() -> Font {
    .system(.callout, design: .default)
  }

  static func caption() -> Font {
    .system(.caption, design: .default)
  }

  static func metric() -> Font {
    .system(.title, design: .rounded).weight(.bold)
  }
}

struct AppTextStyles {
  static func screenTitle(_ text: String) -> some View {
    Text(text)
      .font(AppTypography.largeTitle())
      .foregroundStyle(AppColors.primaryText)
      .accessibilityAddTraits(.isHeader)
  }

  static func screenSubtitle(_ text: String) -> some View {
    Text(text)
      .font(AppTypography.body())
      .foregroundStyle(AppColors.secondaryText)
  }
}
