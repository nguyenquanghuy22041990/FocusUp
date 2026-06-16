//
//  TabCoordinator.swift
//  FocusUp
//

import Observation
import SwiftUI

/// Per-tab navigation path owner. One instance per root tab.
@MainActor
@Observable
final class TabCoordinator<Route: NavigationRoute> {
  var path: [Route]

  init(path: [Route] = []) {
    self.path = path
  }

  func push(_ route: Route) {
    path.append(route)
  }

  func pop() {
    guard !path.isEmpty else { return }
    path.removeLast()
  }

  func popToRoot() {
    path.removeAll()
  }

  func setPath(_ routes: [Route]) {
    path = routes
  }
}
