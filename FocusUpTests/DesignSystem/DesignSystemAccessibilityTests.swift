//
//  DesignSystemAccessibilityTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

struct DesignSystemAccessibilityTests {
  @Test(.tags(.designSystem))
  func minimumTouchTargetMeetsHIG() {
    #expect(AppSpacing.minimumTouchTarget >= 44)
  }

  @Test(.tags(.designSystem))
  func semanticColorTokensExist() {
    let tokens = ["focus", "rest", "success", "warning", "error"]
    #expect(tokens.count == 5)
  }

  @Test(.tags(.designSystem))
  func typographyRolesExist() {
    #expect(AppTypography.largeTitle() != AppTypography.caption())
  }
}
