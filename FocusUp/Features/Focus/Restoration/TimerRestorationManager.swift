//
//  TimerRestorationManager.swift
//  FocusUp
//

import Foundation

enum TimerRestorationManager {
  private static let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }()

  private static let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }()

  static let expirationInterval: TimeInterval = 24 * 60 * 60

  static func encode(_ snapshot: SessionTimerRestorationSnapshot) -> Data? {
    try? encoder.encode(snapshot)
  }

  static func decode(_ data: Data?) -> SessionTimerRestorationSnapshot? {
    guard let data, !data.isEmpty else { return nil }
    guard let snapshot = try? decoder.decode(SessionTimerRestorationSnapshot.self, from: data) else {
      return nil
    }
    if Date().timeIntervalSince(snapshot.savedAt) > expirationInterval {
      return nil
    }
    return snapshot
  }

  static func reconcile(
    _ snapshot: SessionTimerRestorationSnapshot,
    at date: Date = .now
  ) -> SessionTimerRestorationSnapshot {
    var timer = snapshot.timerSnapshot
    timer.lastUpdatedAt = date

    if timer.state == .running {
      if timer.remainingSeconds(at: date) <= 0 {
        timer.state = .completed
        timer.accumulatedElapsedSeconds = timer.configuration.totalDurationSeconds
        timer.segmentStartedAt = nil
      } else if timer.segmentStartedAt == nil {
        timer.segmentStartedAt = date
      }
    }

    return SessionTimerRestorationSnapshot(
      sessionID: snapshot.sessionID,
      timerSnapshot: timer,
      savedAt: date
    )
  }
}
