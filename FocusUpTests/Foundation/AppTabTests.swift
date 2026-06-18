//
//  AppTabTests.swift
//  FocusUpTests
//

import Testing
@testable import FocusUp

struct AppTabTests {
  @Test(.tags(.foundation, .navigation))
  func tabMetadataIsNonEmpty() {
    for tab in AppTab.allCases {
      #expect(!tab.title.isEmpty)
      #expect(!tab.systemImage.isEmpty)
      #expect(!tab.accessibilityLabel.isEmpty)
    }
  }
}
