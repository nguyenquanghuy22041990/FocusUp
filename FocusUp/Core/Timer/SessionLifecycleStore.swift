//
//  SessionLifecycleStore.swift
//  FocusUp
//

import Foundation

@MainActor
struct SessionLifecycleStore<Session: TimedPersistableSession> {
  var fetchActive: () async throws -> Session?
  var fetch: (UUID) async throws -> Session?
  var save: (Session) async throws -> Void
}
