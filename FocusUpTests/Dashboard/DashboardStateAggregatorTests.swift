//
//  DashboardStateAggregatorTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

struct DashboardStateAggregatorTests {
  @Test(.tags(.dashboard))
  func activeFocusMoodWhenSessionRunning() {
    let session = FocusSession(title: "Focus", status: .active)
    let mood = DashboardStateAggregator.resolveMood(
      statistics: StatisticsPreviewData.populated,
      tasks: [],
      hasActiveFocus: true,
      todayFocusMinutes: 0,
      now: .now,
      calendar: .current
    )
    #expect(mood == .activeFocus)
    #expect(session.status.isActiveLifecycle)
  }

  @Test(.tags(.dashboard))
  func emptyMoodForNewUser() {
    let mood = DashboardStateAggregator.resolveMood(
      statistics: .empty,
      tasks: [],
      hasActiveFocus: false,
      todayFocusMinutes: 0,
      now: .now,
      calendar: .current
    )
    #expect(mood == .empty)
  }

  @Test(.tags(.dashboard))
  func continuityReflectsPausedSession() {
    let session = FocusSession(title: "Paused", status: .paused)
    let continuity = DashboardStateAggregator.buildSnapshot(
      statistics: StatisticsPreviewData.populated,
      tasks: [],
      activeFocus: session,
      activeRest: false,
      now: .now,
      calendar: .current
    ).continuity

    #expect(continuity.hasActiveFocus)
    #expect(continuity.canResumeFocus)
    #expect(continuity.restorationHint?.contains("paused") == true)
  }

  @Test(.tags(.dashboard))
  @MainActor
  func activeSessionSnapshotUsesTimerEngine() {
    let engine = TimerEngine(configuration: TimerConfiguration(totalDurationSeconds: 600))
    engine.start(at: Date(timeIntervalSince1970: 0))
    let session = FocusSession(
      title: "Work",
      plannedDurationSeconds: 600,
      status: .active,
      segmentStartedAt: Date(timeIntervalSince1970: 0)
    )
    let snapshot = DashboardStateAggregator.activeSessionSnapshot(
      session: session,
      taskTitle: "Write",
      timerEngine: engine,
      now: Date(timeIntervalSince1970: 120)
    )
    #expect(snapshot.progress > 0)
    #expect(snapshot.remainingLabel == "8:00")
    #expect(snapshot.taskTitle == "Write")
  }
}
