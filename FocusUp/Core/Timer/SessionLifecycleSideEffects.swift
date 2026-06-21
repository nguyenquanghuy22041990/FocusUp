//
//  SessionLifecycleSideEffects.swift
//  FocusUp
//

import Foundation

@MainActor
struct SessionLifecycleSideEffects<Session: TimedPersistableSession> {
  var onAfterStart: ((Session, Date) async -> Void)?
  var onAfterPause: ((Session, Date) async -> Void)?
  var onAfterResume: ((Session, Date) async -> Void)?
  var onAfterComplete: ((Session, Date) async -> Void)?
  var onAfterCancel: ((Session, Date) async -> Void)?
  var onAfterRestore: ((Session, Date) async -> Void)?
  var onAfterRestoreSync: ((Session, Date) async -> Void)?
  var playAmbientSound: (() -> Void)?
  var stopAmbientSound: (() -> Void)?
}
