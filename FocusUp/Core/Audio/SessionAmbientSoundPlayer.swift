//
//  SessionAmbientSoundPlayer.swift
//  FocusUp
//

import AVFoundation
import Foundation

@MainActor
final class SessionAmbientSoundPlayer: SessionAmbientSoundPlaying {
  private var player: AVAudioPlayer?
  private(set) var activeCategory: SessionAmbientSoundCategory?

  func play(category: SessionAmbientSoundCategory) {
    guard activeCategory != category || player?.isPlaying != true else { return }

    guard let url = SessionAmbientSoundCatalog.randomURL(for: category) else {
      stop()
      return
    }

    stop()
    activateAudioSession()

    do {
      let newPlayer = try AVAudioPlayer(contentsOf: url)
      newPlayer.numberOfLoops = -1
      newPlayer.prepareToPlay()
      newPlayer.play()
      player = newPlayer
      activeCategory = category
    } catch {
      stop()
    }
  }

  func stop() {
    player?.stop()
    player = nil
    activeCategory = nil
    deactivateAudioSessionIfNeeded()
  }

  // MARK: - Private

  private func activateAudioSession() {
    let session = AVAudioSession.sharedInstance()
    try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
    try? session.setActive(true)
  }

  private func deactivateAudioSessionIfNeeded() {
    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
  }
}
