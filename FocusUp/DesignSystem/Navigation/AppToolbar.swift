//
//  AppToolbar.swift
//  FocusUp
//

import SwiftUI

struct AppToolbarAction {
  let title: String
  let systemImage: String
  let action: () -> Void

  var accessibilityLabel: String { title }
}

struct AppToolbar: ToolbarContent {
  var leading: [AppToolbarAction] = []
  var trailing: [AppToolbarAction] = []

  var body: some ToolbarContent {
    ToolbarItemGroup(placement: .topBarLeading) {
      ForEach(leading.indices, id: \.self) { index in
        toolbarButton(leading[index])
      }
    }

    ToolbarItemGroup(placement: .topBarTrailing) {
      ForEach(trailing.indices, id: \.self) { index in
        toolbarButton(trailing[index])
      }
    }
  }

  private func toolbarButton(_ item: AppToolbarAction) -> some View {
    Button(action: item.action) {
      Label(item.title, systemImage: item.systemImage)
    }
    .frame(minWidth: AppSpacing.minimumTouchTarget, minHeight: AppSpacing.minimumTouchTarget)
    .accessibilityLabel(item.accessibilityLabel)
  }
}
