//
//  RestTimerViewModel.swift
//  FocusUp
//

import Foundation
import Observation

enum RestTimerInteractionState: Equatable {
  case setup
  case running
  case paused
  case performingAction
  case completed
  case idle
}

enum RestTimerAnimationPhase: Equatable {
  case setup
  case active
  case paused
  case completed
}

@MainActor
@Observable
final class RestTimerViewModel {
  private let sessionManager: RestSessionManager

  var selectedPreset: FocusDurationPreset = .fifteen
  var isStarting = false
  var isPerformingAction = false
  var errorMessage: String?
  var showCompletionBanner = false

  init(sessionManager: RestSessionManager) {
    self.sessionManager = sessionManager
  }

  var hasActiveSession: Bool {
    sessionManager.activeSession != nil
  }

  var animationPhase: RestTimerAnimationPhase {
    switch interactionState {
    case .setup, .idle: .setup
    case .running, .performingAction: .active
    case .paused: .paused
    case .completed: .completed
    }
  }

  var interactionState: RestTimerInteractionState {
    if isPerformingAction { return .performingAction }
    if showCompletionBanner, sessionManager.activeSession == nil { return .completed }
    guard let session = sessionManager.activeSession else { return .setup }

    switch session.status {
    case .active: return .running
    case .paused: return .paused
    case .completed: return .completed
    default: return .setup
    }
  }

  var locksBackNavigation: Bool {
    guard let session = sessionManager.activeSession else { return false }
    return session.status.isActiveLifecycle
  }

  var sessionTitle: String {
    sessionManager.activeSession?.title ?? "Rest Break"
  }

  var statusAccessibilityLabel: String {
    sessionManager.activeSession?.accessibilityStatusLabel ?? "Ready to rest"
  }

  var canStart: Bool {
    !isStarting && sessionManager.activeSession == nil
  }

  func startSession() async -> Bool {
    guard canStart else { return false }
    isStarting = true
    errorMessage = nil

    do {
      try await sessionManager.startSession(
        durationSeconds: selectedPreset.durationSeconds
      )
      isStarting = false
      return true
    } catch {
      errorMessage = error.localizedDescription
      isStarting = false
      return false
    }
  }

  func advanceTimerTick() async {
    let snapshot = await sessionManager.tick()
    if snapshot.state == .completed {
      showCompletionBanner = true
    }
  }

  func progress(at date: Date) -> Double {
    sessionManager.timerEngine.progress(at: date)
  }

  func remainingSeconds(at date: Date) -> Int {
    sessionManager.timerEngine.remainingSeconds(at: date)
  }

  func remainingLabel(at date: Date) -> String {
    FocusTimerFormatting.remainingLabel(seconds: remainingSeconds(at: date))
  }

  func remainingAccessibilityDescription(at date: Date) -> String {
    sessionManager.activeSession?.accessibilityRemainingDescription(at: date)
      ?? remainingLabel(at: date)
  }

  func pause() async {
    await performAction { try await sessionManager.pauseSession() }
  }

  func resume() async {
    await performAction { try await sessionManager.resumeSession() }
  }

  func cancel() async -> Bool {
    await performAction { try await sessionManager.cancelSession() }
  }

  func complete() async -> Bool {
    let success = await performAction { try await sessionManager.completeSession() }
    if success { showCompletionBanner = true }
    return success
  }

  // MARK: - Private

  @discardableResult
  private func performAction(_ action: () async throws -> Void) async -> Bool {
    isPerformingAction = true
    errorMessage = nil

    do {
      try await action()
      isPerformingAction = false
      return true
    } catch {
      errorMessage = error.localizedDescription
      isPerformingAction = false
      return false
    }
  }
}
