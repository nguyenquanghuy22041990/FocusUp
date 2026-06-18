//
//  FocusUpTests.swift
//  FocusUpTests
//
//  Created by Quang Huy Nguyen on 18/5/26.
//

import Testing
@testable import FocusUp

/// Legacy placeholder — foundation tests live under `Foundation/`.
struct FocusUpTests {
  @Test(.tags(.foundation))
  func testTargetLoads() {
    #expect(AppTab.dashboard.title == "Dashboard")
  }
}
