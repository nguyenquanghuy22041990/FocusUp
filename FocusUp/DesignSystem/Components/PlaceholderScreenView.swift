//
//  PlaceholderScreenView.swift
//  FocusUp
//

import SwiftUI

struct PlaceholderScreenView<ExtraContent: View>: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  let title: String
  let subtitle: String
  let systemImage: String
  var wideLayout: Bool = false
  @ViewBuilder var extraContent: () -> ExtraContent

  init(
    title: String,
    subtitle: String,
    systemImage: String,
    wideLayout: Bool = false,
    @ViewBuilder extraContent: @escaping () -> ExtraContent = { EmptyView() }
  ) {
    self.title = title
    self.subtitle = subtitle
    self.systemImage = systemImage
    self.wideLayout = wideLayout
    self.extraContent = extraContent
  }

  var body: some View {
    ResponsiveContainer(wide: wideLayout) {
      VStack(alignment: .leading, spacing: AdaptiveSpacing.sectionSpacing(horizontalSizeClass: horizontalSizeClass)) {
        header
        placeholderCard
        extraContent()
        actionRow
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.large)
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
      AppTextStyles.screenTitle(title)
      AppTextStyles.screenSubtitle(subtitle)
    }
    .accessibilityElement(children: .combine)
  }

  private var placeholderCard: some View {
    AppCard {
      AdaptiveStack(alignment: .leading, spacing: AppSpacing.md) {
        Image(systemName: systemImage)
          .font(.system(size: 32))
          .foregroundStyle(AppColors.focus)
          .frame(minWidth: AppSpacing.minimumTouchTarget, minHeight: AppSpacing.minimumTouchTarget)
          .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: AppSpacing.xs) {
          Text("Coming soon")
            .appFont(.headline)
          Text("This area will host production UI in a later step.")
            .appFont(.body)
            .appMultilineText()
            .foregroundStyle(AppColors.secondaryText)
        }
      }
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(title). Coming soon.")
  }

  private var actionRow: some View {
    AdaptiveContent {
      HStack(spacing: AppSpacing.md) {
        PrimaryButton(title: "Primary action", isDisabled: true, action: {})
        SecondaryButton(title: "Secondary", isDisabled: true, action: {})
      }
    } fallback: {
      VStack(spacing: AppSpacing.md) {
        PrimaryButton(title: "Primary action", isDisabled: true, action: {})
        SecondaryButton(title: "Secondary", isDisabled: true, action: {})
      }
    }
  }
}
