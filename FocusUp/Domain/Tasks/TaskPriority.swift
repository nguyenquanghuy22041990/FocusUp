//
//  TaskPriority.swift
//  FocusUp
//

import Foundation

enum TaskPriority: String, Codable, CaseIterable, Sendable, Identifiable {
  case low
  case medium
  case high

  var id: String { rawValue }

  var title: String {
    switch self {
    case .low: "Low"
    case .medium: "Medium"
    case .high: "High"
    }
  }
}
