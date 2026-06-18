//
//  FocusTimerViewModel.swift
//  FocusUp
//

import Foundation
import Observation

enum FocusTimerInteractionState: Equatable {
  case running
  case paused
  case performingAction
  case completed
  case idle
}

@MainActor
@Observable
final class FocusTimerViewModel {
  private let sessionManager: FocusSessionManager
  private let taskRepository: any TaskRepository

  var isPerformingAction = false
  var associatedTask: Task?
  var errorMessage: String?
  var showCompletionBanner = false

  init(
    sessionManager: FocusSessionManager,
    taskRepository: any TaskRepository
  ) {
    self.sessionManager = sessionManager
    self.taskRepository = taskRepository
  }

  var interactionState: FocusTimerInteractionState {
    if isPerformingAction { return .performingAction }
    if showCompletionBanner, sessionManager.activeSession == nil { return .completed }
    guard let session = sessionManager.activeSession else { return .idle }

    switch session.status {
    case .active: return .running
    case .paused: return .paused
    case .completed: return .completed
    default: return .idle
    }
  }

  var hasActiveSession: Bool {
    sessionManager.activeSession != nil
  }

  /// True while a focus session is in progress (running or paused).
  var locksBackNavigation: Bool {
    guard let session = sessionManager.activeSession else { return false }
    return session.status.isActiveLifecycle
  }

  var sessionTitle: String {
    sessionManager.activeSession?.title ?? "Focus"
  }

  var statusAccessibilityLabel: String {
    sessionManager.activeSession?.accessibilityStatusLabel ?? "No active session"
  }

  func loadAssociatedTask() async {
    guard let taskID = sessionManager.activeSession?.associatedTaskID else {
      associatedTask = nil
      return
    }
    associatedTask = try? await taskRepository.fetch(id: taskID)
  }

  /// Advances the engine clock; call from a background task, not from `body`.
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

  func elapsedAccessibilityDescription(at date: Date) -> String {
    sessionManager.activeSession?.accessibilityElapsedDescription(at: date)
      ?? "No elapsed time"
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
    if success {
      showCompletionBanner = true
    }
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
