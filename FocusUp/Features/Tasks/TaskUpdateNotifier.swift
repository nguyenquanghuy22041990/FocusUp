//
//  TaskUpdateNotifier.swift
//  FocusUp
//

import Foundation

enum TaskUpdateNotifier {
  static let name = Notification.Name("FocusUp.task.updated")

  static func post(taskID: UUID) {
    NotificationCenter.default.post(name: name, object: taskID)
  }
}
