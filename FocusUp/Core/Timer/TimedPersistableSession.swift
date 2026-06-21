//
//  TimedPersistableSession.swift
//  FocusUp
//

import Foundation

protocol TimedSessionStatus: Equatable, Sendable {
  var isActiveLifecycle: Bool { get }
  var timerState: TimerState { get }
}

protocol TimedPersistableSession {
  associatedtype Status: TimedSessionStatus

  var id: UUID { get }
  var plannedDurationSeconds: Int { get }
  var elapsedSeconds: Int { get set }
  var segmentStartedAt: Date? { get set }
  var sessionStartedAt: Date? { get set }
  var completedAt: Date? { get set }
  var status: Status { get set }

  mutating func applyTimerSnapshotForPersistence(_ snapshot: TimerSnapshot, at date: Date)
}

extension FocusSessionStatus: TimedSessionStatus {}

extension RestSessionStatus: TimedSessionStatus {}

extension FocusSession: TimedPersistableSession {
  typealias Status = FocusSessionStatus
}

extension RestSession: TimedPersistableSession {
  typealias Status = RestSessionStatus
}
