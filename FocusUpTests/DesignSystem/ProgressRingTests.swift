//
//  ProgressRingTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

struct ProgressRingLogicTests {
  @Test(.tags(.designSystem))
  func progressClampingLogic() {
    #expect(ProgressRingLogic.clampedProgress(-0.2) == 0)
    #expect(ProgressRingLogic.clampedProgress(0.5) == 0.5)
    #expect(ProgressRingLogic.clampedProgress(1.4) == 1)
  }
}
