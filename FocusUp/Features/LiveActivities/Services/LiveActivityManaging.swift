//
//  LiveActivityManaging.swift
//  FocusUp
//

import Foundation

@MainActor
protocol LiveActivityManaging: AnyObject {
  func startFocus(session: FocusSession, now: Date) async
  func startRest(session: RestSession, now: Date) async
  func syncFocus(session: FocusSession, now: Date) async
  func syncRest(session: RestSession, now: Date) async
  func end(immediate: Bool) async
}

@MainActor
final class NoOpLiveActivityManager: LiveActivityManaging {
  func startFocus(session: FocusSession, now: Date) async {}
  func startRest(session: RestSession, now: Date) async {}
  func syncFocus(session: FocusSession, now: Date) async {}
  func syncRest(session: RestSession, now: Date) async {}
  func end(immediate: Bool) async {}
}
