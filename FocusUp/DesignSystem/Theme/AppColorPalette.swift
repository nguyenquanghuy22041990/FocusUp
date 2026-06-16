//
//  AppColorPalette.swift
//  FocusUp
//

import SwiftUI
import UIKit

extension AppColors {
  // MARK: - Brand & session semantics

  static let focus = dynamicColor(
    light: UIColor(red: 0.12, green: 0.45, blue: 0.86, alpha: 1),
    dark: UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 1)
  )

  static let rest = dynamicColor(
    light: UIColor(red: 0.36, green: 0.62, blue: 0.54, alpha: 1),
    dark: UIColor(red: 0.55, green: 0.82, blue: 0.72, alpha: 1)
  )

  // MARK: - Feedback

  static let success = dynamicColor(
    light: UIColor(red: 0.16, green: 0.57, blue: 0.36, alpha: 1),
    dark: UIColor(red: 0.38, green: 0.78, blue: 0.52, alpha: 1)
  )

  static let warning = dynamicColor(
    light: UIColor(red: 0.79, green: 0.52, blue: 0.10, alpha: 1),
    dark: UIColor(red: 0.96, green: 0.72, blue: 0.32, alpha: 1)
  )

  static let error = dynamicColor(
    light: UIColor(red: 0.78, green: 0.20, blue: 0.24, alpha: 1),
    dark: UIColor(red: 1.0, green: 0.45, blue: 0.48, alpha: 1)
  )

  // MARK: - Surfaces

  static var surfaceElevated: Color {
    Color(uiColor: .tertiarySystemGroupedBackground)
  }

  static var surfaceOverlay: Color {
    Color.primary.opacity(0.05)
  }

  static var onPrimary: Color {
    Color.white
  }

  static var onFocus: Color {
    Color.white
  }

  // MARK: - Helpers

  static func dynamicColor(light: UIColor, dark: UIColor) -> Color {
    Color(
      uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark ? dark : light
      }
    )
  }

  static func background(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? Color(uiColor: .systemBackground) : background
  }

  static func surface(for colorScheme: ColorScheme) -> Color {
    colorScheme == .dark ? surfaceElevated : surface
  }
}
