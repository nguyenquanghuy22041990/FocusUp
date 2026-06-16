//
//  AppSpacingScaleTests.swift
//  FocusUpTests
//

import SwiftUI
import Testing
@testable import FocusUp

struct AppSpacingScaleTests {
  @Test(.tags(.designSystem))
  func regularWidthIncreasesSpacing() {
    let compact = AppSpacingScale.scaled(
      AppSpacing.lg,
      horizontalSizeClass: .compact,
      dynamicTypeSize: .medium
    )
    let regular = AppSpacingScale.scaled(
      AppSpacing.lg,
      horizontalSizeClass: .regular,
      dynamicTypeSize: .medium
    )
    #expect(regular > compact)
  }

  @Test(.tags(.designSystem))
  func accessibilityTypeIncreasesSpacing() {
    let standard = AppSpacingScale.scaled(
      AppSpacing.md,
      horizontalSizeClass: .compact,
      dynamicTypeSize: .medium
    )
    let accessibility = AppSpacingScale.scaled(
      AppSpacing.md,
      horizontalSizeClass: .compact,
      dynamicTypeSize: .accessibility3
    )
    #expect(accessibility > standard)
  }
}
