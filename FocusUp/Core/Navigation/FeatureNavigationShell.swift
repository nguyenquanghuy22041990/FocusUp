//
//  FeatureNavigationShell.swift
//  FocusUp
//

import SwiftUI

/// Wraps a feature root in a restoration-safe `NavigationStack`.
struct FeatureNavigationShell<Route: NavigationRoute, Root: View, Destination: View>: View {
  @Bindable var coordinator: TabCoordinator<Route>
  @ViewBuilder var root: () -> Root
  @ViewBuilder var destination: (Route) -> Destination

  var body: some View {
    NavigationStack(path: $coordinator.path) {
      root()
        .navigationDestination(for: Route.self, destination: destination)
    }
  }
}
