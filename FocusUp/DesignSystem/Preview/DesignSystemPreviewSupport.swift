//
//  DesignSystemPreviewSupport.swift
//  FocusUp
//

import SwiftUI

enum DesignSystemPreviewSupport {
  static let galleryTitle = "Design System Gallery"
}

struct DesignSystemGalleryContainer<Content: View>: View {
  @ViewBuilder var content: () -> Content

  var body: some View {
    ScrollView {
      ReadableContentView {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
          content()
        }
        .adaptiveContentPadding()
      }
    }
    .background(AppColors.background)
  }
}

struct DesignSystemPreviewMatrix<Content: View>: View {
  let name: String
  @ViewBuilder var content: () -> Content

  var body: some View {
    Group {
      content()
        .previewDisplayName("\(name) – Light")
        .preferredColorScheme(.light)

      content()
        .previewDisplayName("\(name) – Dark")
        .preferredColorScheme(.dark)

      content()
        .previewDisplayName("\(name) – Large Text")
        .environment(\.dynamicTypeSize, .accessibility3)

      content()
        .previewDisplayName("\(name) – Regular Width")
        .environment(\.horizontalSizeClass, .regular)
    }
  }
}
