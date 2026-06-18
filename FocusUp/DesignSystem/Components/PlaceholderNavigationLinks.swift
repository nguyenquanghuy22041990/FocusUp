//
//  PlaceholderNavigationLinks.swift
//  FocusUp
//

import SwiftUI

struct PlaceholderNavigationLinks<Route: NavigationRoute>: View {
  let sectionTitle: String
  let routes: [Route]

  var body: some View {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
      Text(sectionTitle)
        .font(AppTypography.headline())
        .foregroundStyle(AppColors.primaryText)
        .accessibilityAddTraits(.isHeader)

      VStack(spacing: AppSpacing.xs) {
        ForEach(routes) { route in
          NavigationLink(value: route) {
            HStack(spacing: AppSpacing.md) {
              Text(route.title)
                .font(AppTypography.body())
                .foregroundStyle(AppColors.primaryText)
              Spacer()
              Image(systemName: "chevron.right")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.secondaryText)
            }
            .frame(minHeight: AppSpacing.minimumTouchTarget)
            .contentShape(Rectangle())
          }
          .accessibilityLabel("Open \(route.title)")
        }
      }
      .padding(AppSpacing.md)
      .background(AppColors.surface)
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    .accessibilityElement(children: .contain)
  }
}
