//
//  ActivityStateMapper.swift
//  FocusUp
//

import Foundation

enum ActivityStateMapper {
  static func mapFocus(_ session: FocusSession, now: Date = .now) -> (
    state: LiveActivitySessionState,
    endDate: Date?,
    pausedRemainingSeconds: Int?,
    progress: Double
  ) {
    let remaining = session.remainingSeconds(at: now)
    let progress = ProgressCalculator.progress(
      totalDurationSeconds: session.plannedDurationSeconds,
      endDate: session.status == .active ? ProgressCalculator.endDate(remainingSeconds: remaining, from: now) : nil,
      pausedRemainingSeconds: session.status == .paused ? remaining : nil,
      now: now
    )

    switch session.status {
    case .active:
      return (.running, ProgressCalculator.endDate(remainingSeconds: remaining, from: now), nil, progress)
    case .paused:
      return (.paused, nil, remaining, progress)
    case .completed:
      return (.completed, nil, nil, 1)
    default:
      return (.running, nil, nil, progress)
    }
  }

  static func mapRest(_ session: RestSession, now: Date = .now) -> (
    state: LiveActivitySessionState,
    endDate: Date?,
    pausedRemainingSeconds: Int?,
    progress: Double
  ) {
    let remaining = session.remainingSeconds(at: now)
    let progress = ProgressCalculator.progress(
      totalDurationSeconds: session.plannedDurationSeconds,
      endDate: session.status == .active ? ProgressCalculator.endDate(remainingSeconds: remaining, from: now) : nil,
      pausedRemainingSeconds: session.status == .paused ? remaining : nil,
      now: now
    )

    switch session.status {
    case .active:
      return (.running, ProgressCalculator.endDate(remainingSeconds: remaining, from: now), nil, progress)
    case .paused:
      return (.paused, nil, remaining, progress)
    case .completed:
      return (.completed, nil, nil, 1)
    default:
      return (.running, nil, nil, progress)
    }
  }
}
