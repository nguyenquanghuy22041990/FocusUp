//
//  SettingsRoute.swift
//  FocusUp
//

import Foundation

enum SettingsRoute: String, NavigationRoute, CaseIterable {
  case appearance
  case notifications
  case about

  var id: String { rawValue }

  var title: String {
    switch self {
    case .appearance: "Appearance"
    case .notifications: "Notifications"
    case .about: "About"
    }
  }
}
