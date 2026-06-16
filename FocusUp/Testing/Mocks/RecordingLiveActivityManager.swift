//
//  RecordingLiveActivityManager.swift
//  FocusUp
//

import Foundation

/// Test double that records Live Activity coordinator calls.
@MainActor
final class RecordingLiveActivityManager: LiveActivityManaging {
  private(set) var startFocusCount = 0
  private(set) var startRestCount = 0
  private(set) var syncFocusCount = 0
  private(set) var syncRestCount = 0
  private(set) var endCount = 0
  private(set) var lastStartFocusSessionID: UUID?
  private(set) var lastEndedImmediate: Bool?

  func startFocus(session: FocusSession, now: Date) async {
    startFocusCount += 1
    lastStartFocusSessionID = session.id
  }

  func startRest(session: RestSession, now: Date) async {
    startRestCount += 1
  }

  func syncFocus(session: FocusSession, now: Date) async {
    syncFocusCount += 1
  }

  func syncRest(session: RestSession, now: Date) async {
    syncRestCount += 1
  }

  func end(immediate: Bool) async {
    endCount += 1
    lastEndedImmediate = immediate
  }
}
