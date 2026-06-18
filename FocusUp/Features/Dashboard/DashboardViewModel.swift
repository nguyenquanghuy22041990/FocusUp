//
//  DashboardViewModel.swift
//  FocusUp
//

import Foundation
import Observation

@MainActor
@Observable
final class DashboardViewModel {
  private let orchestrator: DashboardOrchestrator

  private(set) var loadingState: DashboardLoadingState = .idle
  private(set) var snapshot: DashboardSnapshot = .empty
  private(set) var activeTaskTitle: String?
  private(set) var sessionActionError: String?
  private(set) var isPerformingSessionAction = false

  init(orchestrator: DashboardOrchestrator) {
    self.orchestrator = orchestrator
  }

  var hasActiveSession: Bool {
    orchestrator.hasActiveFocusSession
  }

  func load() async {
    loadingState = .loading
    sessionActionError = nil
    do {
      snapshot = try await orchestrator.refresh()
      loadingState = .loaded
      await refreshActiveTaskTitle()
    } catch {
      loadingState = .failed(error.localizedDescription)
    }
  }

  func refresh() async {
    sessionActionError = nil
    do {
      snapshot = try await orchestrator.refresh(invalidateStatisticsCache: true)
      loadingState = .loaded
      await refreshActiveTaskTitle()
    } catch {
      loadingState = .failed(error.localizedDescription)
    }
  }

  func refreshActiveTaskTitle() async {
    guard let session = orchestrator.activeFocusSession else {
      activeTaskTitle = nil
      return
    }
    activeTaskTitle = await orchestrator.associatedTaskTitle(for: session)
  }

  func activeSession(at date: Date) -> DashboardActiveSessionSnapshot? {
    orchestrator.activeSessionSnapshot(at: date, taskTitle: activeTaskTitle)
  }

  /// Lightweight rebuild when focus/rest session identity changes (no cache invalidation).
  func onSessionContinuityChanged() async {
    await refreshActiveTaskTitle()
    do {
      snapshot = try await orchestrator.refresh()
    } catch {
      // Keep prior snapshot on transient failure.
    }
  }

  func pauseSession() async {
    await performSessionAction { try await orchestrator.pauseActiveSession() }
  }

  func resumeSession() async {
    await performSessionAction { try await orchestrator.resumeActiveSession() }
  }

  func openFocusSession(using coordinator: AppCoordinator) {
    coordinator.openFocusTab(hasActiveSession: orchestrator.hasActiveFocusSession)
  }

  func openRestSession(using coordinator: AppCoordinator) {
    coordinator.openRestTab(hasActiveRestSession: orchestrator.hasActiveRestSession)
  }

  func openTask(_ taskID: UUID, using coordinator: AppCoordinator) {
    coordinator.selectTab(.tasks)
    coordinator.tabCoordinators.tasks.push(.detail(taskID))
  }

  #if DEBUG
  func configureForPreview(snapshot: DashboardSnapshot, activeTaskTitle: String? = nil) {
    self.snapshot = snapshot
    self.activeTaskTitle = activeTaskTitle
    loadingState = .loaded
  }
  #endif

  // MARK: - Private

  private func performSessionAction(_ action: () async throws -> Void) async {
    isPerformingSessionAction = true
    sessionActionError = nil
    do {
      try await action()
      await onSessionContinuityChanged()
    } catch {
      sessionActionError = error.localizedDescription
    }
    isPerformingSessionAction = false
  }
}
