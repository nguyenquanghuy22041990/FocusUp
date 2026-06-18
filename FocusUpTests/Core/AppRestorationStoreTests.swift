//
//  AppRestorationStoreTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@Suite(.tags(.foundation, .production))
struct AppRestorationStoreTests {
  @Test
  func navigationRoundTrip() {
    defer { AppRestorationStore.saveNavigation(.empty) }

    var state = PersistedNavigationState.empty
    state.selectedTab = .tasks
    AppRestorationStore.saveNavigation(state)

    let loaded = AppRestorationStore.loadNavigation()
    #expect(loaded?.selectedTab == .tasks)
  }

  @Test
  func focusTimerSnapshotRoundTrip() {
    defer { AppRestorationStore.saveFocusTimerSnapshot(nil) }

    let payload = Data("focus-timer".utf8)
    AppRestorationStore.saveFocusTimerSnapshot(payload)

    #expect(AppRestorationStore.loadFocusTimerSnapshot() == payload)
    AppRestorationStore.saveFocusTimerSnapshot(nil)
    #expect(AppRestorationStore.loadFocusTimerSnapshot() == nil)
  }

  @Test
  func restTimerSnapshotRoundTrip() {
    defer { AppRestorationStore.saveRestTimerSnapshot(nil) }

    let payload = Data("rest-timer".utf8)
    AppRestorationStore.saveRestTimerSnapshot(payload)

    #expect(AppRestorationStore.loadRestTimerSnapshot() == payload)
    AppRestorationStore.saveRestTimerSnapshot(nil)
    #expect(AppRestorationStore.loadRestTimerSnapshot() == nil)
  }

  @Test
  func createTaskDraftRoundTrip() {
    defer { AppRestorationStore.saveCreateTaskDraft(nil) }

    let payload = Data("create-task".utf8)
    AppRestorationStore.saveCreateTaskDraft(payload)

    #expect(AppRestorationStore.loadCreateTaskDraft() == payload)
    AppRestorationStore.saveCreateTaskDraft(nil)
    #expect(AppRestorationStore.loadCreateTaskDraft() == nil)
  }
}
