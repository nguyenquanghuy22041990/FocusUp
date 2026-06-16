//
//  RestTimerRestorationModifier.swift
//  FocusUp
//

import SwiftUI

/// Persists rest timer state to SceneStorage and app-wide backup. Restore runs in `AppRestorationCoordinator`.
struct RestTimerRestorationModifier: ViewModifier {
  let manager: RestSessionManager

  @SceneStorage(TimerRestorationKeys.restTimerSnapshot) private var persistedData: Data?
  @Environment(\.scenePhase) private var scenePhase

  @State private var isPersistenceEnabled = false

  func body(content: Content) -> some View {
    content
      .onAppear {
        isPersistenceEnabled = true
      }
      .onChange(of: scenePhase) { _, newPhase in
        guard newPhase == .background || newPhase == .inactive else { return }
        persistCurrentState()
      }
      .onChange(of: manager.activeSession?.id) { _, newID in
        if newID == nil {
          persistedData = nil
          AppRestorationStore.saveRestTimerSnapshot(nil)
          return
        }
        persistIfReady()
      }
  }

  private func persistIfReady() {
    guard isPersistenceEnabled else { return }
    persistCurrentState()
  }

  private func persistCurrentState() {
    guard let data = encodedSnapshot() else {
      persistedData = nil
      AppRestorationStore.saveRestTimerSnapshot(nil)
      return
    }
    persistedData = data
    AppRestorationStore.saveRestTimerSnapshot(data)
  }

  private func encodedSnapshot() -> Data? {
    guard let snapshot = manager.exportRestorationSnapshot() else { return nil }
    let stamped = SessionTimerRestorationSnapshot(
      sessionID: snapshot.sessionID,
      timerSnapshot: snapshot.timerSnapshot,
      savedAt: Date()
    )
    return TimerRestorationManager.encode(stamped)
  }
}

extension View {
  func restTimerRestoration(manager: RestSessionManager) -> some View {
    modifier(RestTimerRestorationModifier(manager: manager))
  }
}
