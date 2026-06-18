//
//  AppTabBar.swift
//  FocusUp
//

import SwiftUI

/// Visual reference for tab styling. Production shell uses SwiftUI `TabView`.
struct AppTabBar: View {
  @Binding var selection: AppTab

  var body: some View {
    HStack {
      ForEach(AppTab.allCases) { tab in
        Button {
          selection = tab
        } label: {
          VStack(spacing: AppSpacing.xxs) {
            Image(systemName: tab.systemImage)
            Text(tab.title)
              .appFont(.caption)
          }
          .frame(maxWidth: .infinity, minHeight: AppSpacing.minimumTouchTarget)
          .foregroundStyle(selection == tab ? AppColors.focus : AppColors.secondaryText)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.accessibilityLabel)
        .accessibilityAddTraits(selection == tab ? .isSelected : [])
      }
    }
    .padding(.horizontal, AppSpacing.sm)
    .padding(.top, AppSpacing.xs)
    .background(AppColors.surface)
  }
}

#Preview {
  @Previewable @State var tab: AppTab = .dashboard
  AppTabBar(selection: $tab)
}
