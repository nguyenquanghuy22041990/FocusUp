//
//  SessionLifecycleError.swift
//  FocusUp
//

import Foundation

enum SessionLifecycleError: Error, Equatable {
  case sessionAlreadyActive
  case noActiveSession
  case sessionNotFound
}

typealias FocusSessionManagerError = SessionLifecycleError
typealias RestSessionManagerError = SessionLifecycleError
