//
//  MockAppCoordinator.swift
//  FocusUp
//

import Foundation

enum MockAppCoordinatorFactory {
  @MainActor
  static func make(selectedTab: AppTab = .dashboard) -> AppCoordinator {
    AppCoordinator(selectedTab: selectedTab)
  }
}
