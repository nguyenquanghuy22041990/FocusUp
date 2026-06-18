//
//  AppCoordinator.swift
//  FocusUp
//

import Observation
import SwiftUI

/// Owns app-level navigation state. Feature coordinators attach here later.
@MainActor
@Observable
final class AppCoordinator {
    var selectedTab: AppTab
    var tabCoordinators: TabCoordinators

    /// True after `AppRestorationCoordinator.performColdRestore` finishes (observable for SwiftUI).
    var hasCompletedColdRestore = false

    /// Incremented when per-scene navigation restoration applies a saved stack.
    var navigationRestoreGeneration = 0

    init(selectedTab: AppTab, tabCoordinators: TabCoordinators) {
        self.selectedTab = selectedTab
        self.tabCoordinators = tabCoordinators
    }

    convenience init(selectedTab: AppTab = .dashboard) {
        self.init(selectedTab: selectedTab, tabCoordinators: TabCoordinators())
    }

    func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }

    func open(_ deepLink: AppDeepLink) {
        switch deepLink {
        case .tab(let tab):
            selectTab(tab)
            popToRoot(for: tab)
        case .dashboard(let route):
            selectTab(.dashboard)
            tabCoordinators.dashboard.setPath([route])
        case .tasks(let route):
            selectTab(.tasks)
            tabCoordinators.tasks.setPath([route])
        case .focus(let route):
            selectTab(.focus)
            tabCoordinators.focus.setPath([route])
        case .statistics(let route):
            selectTab(.statistics)
            tabCoordinators.statistics.setPath([route])
        case .settings(let route):
            selectTab(.settings)
            tabCoordinators.settings.setPath([route])
        }
    }

    func popToRoot(for tab: AppTab) {
        switch tab {
        case .dashboard: tabCoordinators.dashboard.popToRoot()
        case .tasks: tabCoordinators.tasks.popToRoot()
        case .focus: tabCoordinators.focus.popToRoot()
        case .statistics: tabCoordinators.statistics.popToRoot()
        case .settings: tabCoordinators.settings.popToRoot()
        }
    }
}

extension AppCoordinator {
    static let preview = AppCoordinator(selectedTab: .dashboard)
    static let testing = AppCoordinator(selectedTab: .focus)
}
