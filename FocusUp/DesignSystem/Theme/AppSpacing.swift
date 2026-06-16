//
//  AppSpacing.swift
//  FocusUp
//

import CoreGraphics
import SwiftUI

enum AppSpacing {
  static let xxs: CGFloat = 4
  static let xs: CGFloat = 8
  static let sm: CGFloat = 12
  static let md: CGFloat = 16
  static let lg: CGFloat = 24
  static let xl: CGFloat = 32
  static let xxl: CGFloat = 48

  /// Minimum recommended touch target (HIG).
  static let minimumTouchTarget: CGFloat = 44

  static let cardRadius: CGFloat = 16
  static let buttonRadius: CGFloat = 12
}

enum AppSpacingScale {
  /// Scales base spacing for regular-width layouts.
  static func scaled(
    _ base: CGFloat,
    horizontalSizeClass: UserInterfaceSizeClass?,
    dynamicTypeSize: DynamicTypeSize
  ) -> CGFloat {
    let widthMultiplier: CGFloat = horizontalSizeClass == .regular ? 1.15 : 1
    let typeMultiplier: CGFloat = dynamicTypeSize.isAccessibilitySize ? 1.1 : 1
    return base * widthMultiplier * typeMultiplier
  }
}

private extension DynamicTypeSize {
  var isAccessibilitySize: Bool {
    switch self {
    case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
      true
    default:
      false
    }
  }
}
