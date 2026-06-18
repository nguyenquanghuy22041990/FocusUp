//
//  RestTimerPreviews.swift
//  FocusUp
//

import SwiftUI

@MainActor
private enum RestTimerPreviewFactory {
  static let container = AppContainer.preview

  static func setupViewModel() -> RestTimerViewModel {
    RestTimerViewModel(sessionManager: container.restSessionManager)
  }

  static func activeViewModel() -> RestTimerViewModel {
    let manager = container.restSessionManager
    manager.configureForPreview(
      session: RestPreviewData.active,
      timerSnapshot: RestPreviewData.activeTimerSnapshot
    )
    return RestTimerViewModel(sessionManager: manager)
  }

  static func pausedViewModel() -> RestTimerViewModel {
    let manager = container.restSessionManager
    manager.configureForPreview(
      session: RestPreviewData.paused,
      timerSnapshot: RestPreviewData.pausedTimerSnapshot
    )
    return RestTimerViewModel(sessionManager: manager)
  }
}

#Preview("Rest – Setup") {
  NavigationStack {
    RestTimerView(viewModel: RestTimerPreviewFactory.setupViewModel(), onSessionEnded: {})
  }
  .appContainer(.preview)
}

#Preview("Rest – Active") {
  NavigationStack {
    RestTimerView(viewModel: RestTimerPreviewFactory.activeViewModel(), onSessionEnded: {})
  }
  .appContainer(.preview)
}

#Preview("Rest – Paused Dark", traits: .landscapeLeft) {
  NavigationStack {
    RestTimerView(viewModel: RestTimerPreviewFactory.pausedViewModel(), onSessionEnded: {})
      .preferredColorScheme(.dark)
  }
  .appContainer(.preview)
}

#Preview("Rest – Accessibility Type") {
  NavigationStack {
    RestTimerView(viewModel: RestTimerPreviewFactory.activeViewModel(), onSessionEnded: {})
      .environment(\.dynamicTypeSize, .accessibility3)
  }
  .appContainer(.preview)
}
