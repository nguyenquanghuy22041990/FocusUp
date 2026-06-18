//
//  SessionAmbientSoundTests.swift
//  FocusUp
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
final class MockSessionAmbientSoundPlayer: SessionAmbientSoundPlaying {
  private(set) var playCount = 0
  private(set) var stopCount = 0
  private(set) var lastPlayedCategory: SessionAmbientSoundCategory?

  func play(category: SessionAmbientSoundCategory) {
    playCount += 1
    lastPlayedCategory = category
  }

  func stop() {
    stopCount += 1
  }
}

@MainActor
struct SessionAmbientSoundTests {
  @Test(.tags(.foundation))
  func focusSessionPlaysAndStopsOnPause() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let sound = MockSessionAmbientSoundPlayer()
    let manager = FocusSessionManager(
      repository: FocusRepositoryImpl(context: persistence.mainContext),
      clock: TestClock(),
      ambientSoundPlayer: sound
    )

    try await manager.startSession(title: "Work", durationSeconds: 60)
    #expect(sound.playCount == 1)
    #expect(sound.lastPlayedCategory == .focus)

    try await manager.pauseSession()
    #expect(sound.stopCount == 1)

    try await manager.resumeSession()
    #expect(sound.playCount == 2)

    try await manager.completeSession()
    #expect(sound.stopCount == 2)
  }

  @Test(.tags(.rest))
  func restSessionPlaysAndStopsOnEnd() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let sound = MockSessionAmbientSoundPlayer()
    let manager = RestSessionManager(
      repository: RestRepositoryImpl(context: persistence.mainContext),
      clock: TestClock(),
      ambientSoundPlayer: sound
    )

    try await manager.startSession(durationSeconds: 60)
    #expect(sound.lastPlayedCategory == .rest)

    try await manager.cancelSession()
    #expect(sound.stopCount >= 1)
  }

  @Test(.tags(.foundation))
  func catalogFindsBundledFocusSounds() {
    let urls = SessionAmbientSoundCatalog.allURLs(for: .focus)
    #expect(!urls.isEmpty)
    #expect(urls.allSatisfy { $0.pathExtension.lowercased() == "mp3" })
  }

  @Test(.tags(.rest))
  func catalogFindsBundledRestSounds() {
    let urls = SessionAmbientSoundCatalog.allURLs(for: .rest)
    #expect(!urls.isEmpty)
  }
}
