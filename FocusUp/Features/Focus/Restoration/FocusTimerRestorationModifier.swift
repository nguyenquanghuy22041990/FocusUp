//
//  FocusTimerRestorationModifier.swift
//  FocusUp
//

import SwiftUI

/// Persists focus timer state to SceneStorage and app-wide backup. Restore runs in `AppRestorationCoordinator`.
struct FocusTimerRestorationModifier: ViewModifier {
  let manager: FocusSessionManager

  @SceneStorage(TimerRestorationKeys.focusTimerSnapshot) private var persistedData: Data?
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
          AppRestorationStore.saveFocusTimerSnapshot(nil)
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
      AppRestorationStore.saveFocusTimerSnapshot(nil)
      return
    }
    persistedData = data
    AppRestorationStore.saveFocusTimerSnapshot(data)
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
  func focusTimerRestoration(manager: FocusSessionManager) -> some View {
    modifier(FocusTimerRestorationModifier(manager: manager))
  }
}
