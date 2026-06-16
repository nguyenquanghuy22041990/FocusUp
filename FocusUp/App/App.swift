//
//  App.swift
//  FocusUp
//

import SwiftData
import SwiftUI

@main
struct FocusUpApp: App {
  @State private var container = AppContainer.live

  var body: some Scene {
    WindowGroup {
      AppRootView()
        .appContainer(container)
    }
    .modelContainer(container.persistence.container)
  }
}
