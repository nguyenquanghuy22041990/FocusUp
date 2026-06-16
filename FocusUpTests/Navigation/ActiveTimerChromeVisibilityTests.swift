//
//  ActiveTimerChromeVisibilityTests.swift
//  FocusUp
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct ActiveTimerChromeVisibilityTests {
  @Test(.tags(.navigation))
  func immersiveModeWhenFocusOrRestActive() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let focus = FocusSessionManager(
      repository: FocusRepositoryImpl(context: persistence.mainContext),
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    let rest = RestSessionManager(
      repository: RestRepositoryImpl(context: persistence.mainContext),
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )

    #expect(!ActiveTimerTabBarVisibility.isImmersiveModeActive(
      focusManager: focus,
      restManager: rest
    ))

    try await focus.startSession(title: "Work", durationSeconds: 60)
    #expect(ActiveTimerTabBarVisibility.isImmersiveModeActive(
      focusManager: focus,
      restManager: rest
    ))

    try await focus.cancelSession()
    try await rest.startSession(durationSeconds: 60)
    #expect(ActiveTimerTabBarVisibility.isImmersiveModeActive(
      focusManager: focus,
      restManager: rest
    ))
  }
}
