//
//  ClockCuckooTests.swift
//  FocusUpTests
//
//  Demonstrates Cuckoo-generated mocks for Sendable protocols.
//  @MainActor repository protocols continue to use hand-written test doubles
//  because Cuckoo's generator crashes on @MainActor annotations (issue #513).
//

import Cuckoo
import Foundation
import Testing
@testable import FocusUp

struct ClockCuckooTests {
  @Test(.tags(.foundation))
  func stubClockReturnsFixedDate() {
    let mock = MockClock()
    let fixed = Date(timeIntervalSince1970: 1_700_000_000)

    stub(mock) { when($0.now()).thenReturn(fixed) }

    #expect(mock.now() == fixed)
    verify(mock).now()
  }

  @Test(.tags(.foundation))
  func stubClockAdvancesAcrossCalls() {
    let mock = MockClock()
    let first = Date(timeIntervalSince1970: 100)
    let second = Date(timeIntervalSince1970: 200)

    stub(mock) { when($0.now()).thenReturn(first).thenReturn(second) }

    #expect(mock.now() == first)
    #expect(mock.now() == second)
  }
}
