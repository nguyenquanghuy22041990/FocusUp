//
//  StatisticsSection.swift
//  FocusUp
//

import SwiftUI

struct StatisticsSection<Content: View>: View {
  let title: String
  var subtitle: String?
  @ViewBuilder var content: () -> Content

  var body: some View {
    VStack(alignment: .leading, spacing: AppSpacing.md) {
      VStack(alignment: .leading, spacing: AppSpacing.xxs) {
        Text(title)
          .appFont(.headline)
          .accessibilityAddTraits(.isHeader)
        if let subtitle {
          Text(subtitle)
            .appFont(.caption)
            .appMultilineText()
            .foregroundStyle(AppColors.secondaryText)
        }
      }
      content()
    }
    .accessibilityElement(children: .contain)
  }
}

struct StatisticsCardGrid<Content: View>: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  var spacing: CGFloat = AppSpacing.md
  @ViewBuilder var content: () -> Content

  var body: some View {
    if horizontalSizeClass == .regular {
      LazyVGrid(
        columns: [
          GridItem(.flexible(), spacing: spacing),
          GridItem(.flexible(), spacing: spacing),
        ],
        spacing: spacing
      ) {
        content()
      }
    } else {
      VStack(spacing: spacing) {
        content()
      }
    }
  }
}
