//
//  DesignSystemGalleryView.swift
//  FocusUp
//

import SwiftUI

struct DesignSystemGalleryView: View {
  @State private var loading = true
  @State private var previewTab: AppTab = .dashboard

  var body: some View {
    DesignSystemGalleryContainer {
      colorsSection
      typographySection
      buttonsSection
      cardsSection
      progressSection
      navigationSection
    }
    .appNavigationBar(DesignSystemPreviewSupport.galleryTitle)
  }

  private var colorsSection: some View {
    gallerySection("Colors") {
      AdaptiveGrid(data: colorSwatches, id: \.name) { swatch in
        RoundedRectangle(cornerRadius: AppSpacing.sm)
          .fill(swatch.color)
          .frame(height: 56)
          .overlay(alignment: .bottomLeading) {
            Text(swatch.name)
              .appFont(.caption)
              .padding(AppSpacing.xs)
              .foregroundStyle(AppColors.onPrimary)
          }
          .accessibilityLabel(swatch.name)
      }
    }
  }

  private var typographySection: some View {
    gallerySection("Typography") {
      Text("Large Title").appFont(.largeTitle)
      Text("Title").appFont(.title)
      Text("Headline").appFont(.headline)
      Text("Body text with multiline support for Dynamic Type.").appFont(.body).appMultilineText()
      Text("Caption").appFont(.caption)
    }
  }

  private var buttonsSection: some View {
    gallerySection("Buttons") {
      PrimaryButton(title: "Primary", action: {})
      SecondaryButton(title: "Secondary", action: {})
      DestructiveButton(title: "Destructive", action: {})
      LoadingButton(title: "Loading", isLoading: loading, action: { loading.toggle() })
    }
  }

  private var cardsSection: some View {
    gallerySection("Cards") {
      DashboardCard(
        title: "Focus Today",
        value: "2h 15m",
        subtitle: "Placeholder metric",
        systemImage: "timer"
      )

      StatisticsCard(title: "Weekly Focus", summary: "Chart placeholder") {
        RoundedRectangle(cornerRadius: AppSpacing.sm)
          .fill(AppColors.focus.opacity(0.2))
      }

      TaskCardContainer(title: "Write project brief", isCompleted: false) {
        Text("Due today")
          .appFont(.caption)
          .foregroundStyle(AppColors.secondaryText)
      }
    }
  }

  private var progressSection: some View {
    gallerySection("Progress") {
      HStack(spacing: AppSpacing.xl) {
        ProgressRingView(progress: 0.35, tint: AppColors.focus)
        ProgressRingView(progress: 0.72, tint: AppColors.rest)
        TimerRingView(progress: 0.5, remainingLabel: "12:30")
      }
    }
  }

  private var navigationSection: some View {
    gallerySection("Navigation") {
      AppTabBar(selection: $previewTab)

      AppCard {
        Text("Toolbar and navigation bar styles are applied via `appNavigationBar` and `AppToolbar`.")
          .appFont(.body)
          .appMultilineText()
          .foregroundStyle(AppColors.secondaryText)
      }
    }
  }

  private func gallerySection<Content: View>(
    _ title: String,
    @ViewBuilder content: () -> Content
  ) -> some View {
    VStack(alignment: .leading, spacing: AppSpacing.md) {
      Text(title)
        .appFont(.title)
        .accessibilityAddTraits(.isHeader)
      content()
    }
  }

  private var colorSwatches: [(name: String, color: Color)] {
    [
      ("Focus", AppColors.focus),
      ("Rest", AppColors.rest),
      ("Success", AppColors.success),
      ("Warning", AppColors.warning),
      ("Error", AppColors.error),
      ("Surface", AppColors.surface)
    ]
  }
}

#Preview {
  NavigationStack {
    DesignSystemGalleryView()
  }
}

#Preview("Gallery Matrix") {
  DesignSystemPreviewMatrix(name: "Gallery") {
    NavigationStack {
      DesignSystemGalleryView()
    }
  }
}
