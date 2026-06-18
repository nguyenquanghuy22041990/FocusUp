//
//  SessionAmbientSoundPlaying.swift
//  FocusUp
//

import Foundation

@MainActor
protocol SessionAmbientSoundPlaying: AnyObject {
  func play(category: SessionAmbientSoundCategory)
  func stop()
}

@MainActor
final class NoOpSessionAmbientSoundPlayer: SessionAmbientSoundPlaying {
  func play(category: SessionAmbientSoundCategory) {}
  func stop() {}
}
