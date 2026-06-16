//
//  AppSidebarView.swift
//  FocusUp
//

import SwiftUI

/// Sidebar list for regular-width layouts (iPad, Stage Manager, split view).
struct AppSidebarView: View {
  @Bindable var coordinator: AppCoordinator

  var body: some View {
    AppSidebar {
      List {
      ForEach(AppTab.allCases) { tab in
        Button {
          coordinator.selectTab(tab)
        } label: {
          HStack {
            Label(tab.title, systemImage: tab.systemImage)
            Spacer()
            if coordinator.selectedTab == tab {
              Image(systemName: "checkmark")
                .foregroundStyle(AppColors.primary)
            }
          }
        }
        .buttonStyle(.plain)
        .frame(minHeight: AppSpacing.minimumTouchTarget)
        .accessibilityLabel(tab.accessibilityLabel)
        .accessibilityAddTraits(coordinator.selectedTab == tab ? .isSelected : [])
      }
      }
    }
    .navigationTitle("FocusUp")
  }
}

#Preview {
  NavigationSplitView {
    AppSidebarView(coordinator: .preview)
  } detail: {
    Text("Detail")
  }
}
