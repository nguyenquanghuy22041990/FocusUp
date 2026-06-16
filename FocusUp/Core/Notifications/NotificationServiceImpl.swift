//
//  NotificationServiceImpl.swift
//  FocusUp
//

import Foundation
import UserNotifications

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class NotificationServiceImpl: NotificationService {
  private let center: UNUserNotificationCenter

  init(center: UNUserNotificationCenter = .current()) {
    self.center = center
  }

  func authorizationStatus() async -> NotificationAuthorizationState {
    let settings = await center.notificationSettings()
    return map(settings.authorizationStatus)
  }

  func requestAuthorization() async -> NotificationAuthorizationState {
    do {
      let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
      return granted ? .authorized : .denied
    } catch {
      return .denied
    }
  }

  func openSystemSettings() {
    #if canImport(UIKit)
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
    #endif
  }

  func schedule(_ request: LocalNotificationRequest) async throws {
    let content = UNMutableNotificationContent()
    content.title = request.title
    content.body = request.body
    content.categoryIdentifier = request.category.rawValue
    content.sound = .default

    let trigger = makeTrigger(for: request)
    let notificationRequest = UNNotificationRequest(
      identifier: request.identifier,
      content: content,
      trigger: trigger
    )
    try await center.add(notificationRequest)
  }

  func cancel(identifiers: [String]) async {
    center.removePendingNotificationRequests(withIdentifiers: identifiers)
    center.removeDeliveredNotifications(withIdentifiers: identifiers)
  }

  func cancelAll() async {
    center.removeAllPendingNotificationRequests()
  }

  func pendingIdentifiers() async -> [String] {
    let pending = await center.pendingNotificationRequests()
    return pending.map(\.identifier)
  }

  // MARK: - Private

  private func makeTrigger(for request: LocalNotificationRequest) -> UNNotificationTrigger? {
    if request.repeatsDaily {
      let components = Calendar.current.dateComponents(
        [.hour, .minute],
        from: request.fireDate
      )
      return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    }

    let interval = request.fireDate.timeIntervalSinceNow
    guard interval > 1 else {
      return UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    }
    return UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
  }

  private func map(_ status: UNAuthorizationStatus) -> NotificationAuthorizationState {
    switch status {
    case .notDetermined: .notDetermined
    case .denied: .denied
    case .authorized: .authorized
    case .provisional: .provisional
    case .ephemeral: .ephemeral
    @unknown default: .denied
    }
  }
}
