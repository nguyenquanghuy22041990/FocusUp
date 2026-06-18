//
//  PreviewDependencies.swift
//  FocusUp
//

import SwiftUI

enum PreviewDependencies {
  static var container: AppContainer { .preview }
  static var coordinator: AppCoordinator { .preview }
  static var taskRepository: any TaskRepository { container.taskRepository }
  static var focusRepository: any FocusRepository { container.focusRepository }
}

extension View {
  func previewAppDependencies() -> some View {
    appContainer(.preview)
  }
}
