//
//  AppColors.swift
//  FocusUp
//

import SwiftUI

enum AppColors {
  /// Brand accent — maps to focus blue for consistency across the app.
  static var primary: Color { focus }

  static let primaryText = Color.primary
  static let secondaryText = Color.secondary
  static let tertiaryText = Color(uiColor: .tertiaryLabel)
  static let separator = Color(uiColor: .separator)

  static var background: Color {
    Color(uiColor: .systemGroupedBackground)
  }

  static var surface: Color {
    Color(uiColor: .secondarySystemGroupedBackground)
  }
}
