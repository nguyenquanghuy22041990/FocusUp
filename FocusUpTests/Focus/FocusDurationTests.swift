//
//  FocusDurationTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@Suite(.tags(.focus, .production))
struct FocusDurationTests {
  @Test
  func remainingSecondsNeverNegative() {
    let duration = FocusDuration(plannedSeconds: 1_500, elapsedSeconds: 2_000)
    #expect(duration.remainingSeconds == 0)
  }

  @Test
  func progressClampsAtOne() {
    let duration = FocusDuration(plannedSeconds: 100, elapsedSeconds: 200)
    #expect(duration.progress == 1)
  }

  @Test
  func progressZeroWhenNoPlannedDuration() {
    let duration = FocusDuration(plannedSeconds: 0, elapsedSeconds: 10)
    #expect(duration.progress == 0)
  }

  @Test
  func initializerClampsNegativeValues() {
    let duration = FocusDuration(plannedSeconds: -10, elapsedSeconds: -5)
    #expect(duration.plannedSeconds == 0)
    #expect(duration.elapsedSeconds == 0)
  }

  @Test
  func fromSessionUsesElapsedAtDate() {
    let start = Date(timeIntervalSince1970: 1_700_000_000)
    var session = DomainFixtures.focusSession(
      status: .active,
      plannedDurationSeconds: 1_800,
      elapsedSeconds: 120,
      segmentStartedAt: start
    )
    session.sessionStartedAt = start

    let duration = FocusDuration.from(session: session, at: start.addingTimeInterval(60))

    #expect(duration.plannedSeconds == 1_800)
    #expect(duration.elapsedSeconds >= 120)
  }
}
