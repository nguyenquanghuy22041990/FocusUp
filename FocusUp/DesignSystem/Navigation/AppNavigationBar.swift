//
//  AppNavigationBar.swift
//  FocusUp
//

import SwiftUI

struct AppNavigationBar: ViewModifier {
  let title: String
  var displayMode: NavigationBarItem.TitleDisplayMode = .large

  func body(content: Content) -> some View {
    content
      .navigationTitle(title)
      .navigationBarTitleDisplayMode(displayMode)
      .toolbarBackground(AppColors.background, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
  }
}

extension View {
  func appNavigationBar(
    _ title: String,
    displayMode: NavigationBarItem.TitleDisplayMode = .large
  ) -> some View {
    modifier(AppNavigationBar(title: title, displayMode: displayMode))
  }
}
