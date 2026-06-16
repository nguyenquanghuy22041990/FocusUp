//
//  NotificationService.swift
//  FocusUp
//

import Foundation

@MainActor
protocol NotificationService: AnyObject {
  func authorizationStatus() async -> NotificationAuthorizationState
  func requestAuthorization() async -> NotificationAuthorizationState
  func openSystemSettings()
  func schedule(_ request: LocalNotificationRequest) async throws
  func cancel(identifiers: [String]) async
  func cancelAll() async
  func pendingIdentifiers() async -> [String]
}

@MainActor
final class NoOpNotificationService: NotificationService {
  var authorization: NotificationAuthorizationState = .authorized
  var scheduled: [LocalNotificationRequest] = []
  private(set) var cancelAllCount = 0
  private(set) var lastCancelledIdentifiers: [String] = []

  func authorizationStatus() async -> NotificationAuthorizationState {
    authorization
  }

  func requestAuthorization() async -> NotificationAuthorizationState {
    authorization = .authorized
    return authorization
  }

  func openSystemSettings() {}

  func schedule(_ request: LocalNotificationRequest) async throws {
    scheduled.append(request)
  }

  func cancel(identifiers: [String]) async {
    lastCancelledIdentifiers = identifiers
    scheduled.removeAll { identifiers.contains($0.identifier) }
  }

  func cancelAll() async {
    cancelAllCount += 1
    scheduled.removeAll()
  }

  func pendingIdentifiers() async -> [String] {
    scheduled.map(\.identifier)
  }
}
