//
//  LiveActivityMapperTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@Suite(.tags(.focus))
struct LiveActivityMapperTests {
  @Test func focusActiveMapsEndDate() {
    let now = Date(timeIntervalSince1970: 1_000)
    var session = FocusSession(
      title: "Design",
      plannedDurationSeconds: 1_500,
      elapsedSeconds: 0,
      status: .active,
      segmentStartedAt: now
    )

    let mapped = ActivityStateMapper.mapFocus(session, now: now)
    #expect(mapped.state == .running)
    #expect(mapped.endDate == now.addingTimeInterval(1_500))
    #expect(mapped.pausedRemainingSeconds == nil)
  }

  @Test func focusPausedMapsStaticRemaining() {
    let now = Date(timeIntervalSince1970: 2_000)
    var session = FocusSession(
      title: "Design",
      plannedDurationSeconds: 1_500,
      elapsedSeconds: 600,
      status: .paused
    )

    let mapped = ActivityStateMapper.mapFocus(session, now: now)
    #expect(mapped.state == .paused)
    #expect(mapped.endDate == nil)
    #expect(mapped.pausedRemainingSeconds == 900)
  }

  @Test func progressCalculatorUsesEndDate() {
    let now = Date(timeIntervalSince1970: 0)
    let end = now.addingTimeInterval(200)
    let progress = ProgressCalculator.progress(
      totalDurationSeconds: 200,
      endDate: end,
      pausedRemainingSeconds: nil,
      now: now.addingTimeInterval(50)
    )
    #expect(progress == 0.25)
  }
}
