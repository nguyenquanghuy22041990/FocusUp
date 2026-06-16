//
//  AppTab.swift
//  FocusUp
//

import SwiftUI

enum AppTab: String, CaseIterable, Identifiable, Hashable, Codable, Sendable {
    case dashboard
    case tasks
    case focus
    case statistics
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .tasks: "Tasks"
        case .focus: "Focus"
        case .statistics: "Statistics"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "house.fill"
        case .tasks: "checklist"
        case .focus: "timer"
        case .statistics: "chart.bar.fill"
        case .settings: "gearshape.fill"
        }
    }

    var accessibilityLabel: String {
        title
    }
}
