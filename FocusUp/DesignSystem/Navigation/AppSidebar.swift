//
//  AppSidebar.swift
//  FocusUp
//

import SwiftUI

/// Styled sidebar container for regular-width navigation layouts.
struct AppSidebar<Content: View>: View {
  @ViewBuilder var content: () -> Content

  var body: some View {
    content()
      .listStyle(.sidebar)
      .scrollContentBackground(.hidden)
      .background(AppColors.background)
  }
}
