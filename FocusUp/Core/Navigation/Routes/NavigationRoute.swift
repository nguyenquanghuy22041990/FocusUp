//
//  NavigationRoute.swift
//  FocusUp
//

import Foundation

/// Shared contract for typed, restoration-safe navigation destinations.
protocol NavigationRoute: Hashable, Codable, Identifiable {
  var title: String { get }
}
