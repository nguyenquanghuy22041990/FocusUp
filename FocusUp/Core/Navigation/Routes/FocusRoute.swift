//
//  FocusRoute.swift
//  FocusUp
//

import Foundation

enum FocusRoute: String, NavigationRoute, CaseIterable {
  case sessionSetup
  case activeSession
  case restSession
  case history

  var id: String { rawValue }

  var title: String {
    switch self {
    case .sessionSetup: "Session Setup"
    case .activeSession: "Active Session"
    case .restSession: "Rest"
    case .history: "History"
    }
  }
}
