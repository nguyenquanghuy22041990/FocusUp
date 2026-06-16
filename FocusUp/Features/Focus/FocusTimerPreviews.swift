//
//  FocusTimerPreviews.swift
//  FocusUp
//

import SwiftUI

@MainActor
private enum FocusTimerPreviewFactory {
  static let container = AppContainer.preview

  static func startViewModel() -> FocusTimerStartViewModel {
    FocusTimerStartViewModel(
      sessionManager: container.focusSessionManager,
      taskRepository: container.taskRepository
    )
  }

  static func timerViewModel(
    session: FocusSession,
    timerSnapshot: TimerSnapshot
  ) -> FocusTimerViewModel {
    let manager = container.focusSessionManager
    manager.configureForPreview(session: session, timerSnapshot: timerSnapshot)
    return FocusTimerViewModel(
      sessionManager: manager,
      taskRepository: container.taskRepository
    )
  }
}

#Preview("Start – iPhone") {
  NavigationStack {
    FocusTimerStartView(
      viewModel: FocusTimerPreviewFactory.startViewModel(),
      onSessionStarted: {}
    )
  }
  .appContainer(.preview)
}

#Preview("Active – Running") {
  NavigationStack {
    FocusTimerView(
      viewModel: FocusTimerPreviewFactory.timerViewModel(
        session: FocusPreviewData.active,
        timerSnapshot: FocusPreviewData.activeTimerSnapshot
      ),
      onSessionEnded: {}
    )
  }
  .appContainer(.preview)
}

#Preview("Active – Paused", traits: .landscapeLeft) {
  NavigationStack {
    FocusTimerView(
      viewModel: FocusTimerPreviewFactory.timerViewModel(
        session: FocusPreviewData.paused,
        timerSnapshot: FocusPreviewData.pausedTimerSnapshot
      ),
      onSessionEnded: {}
    )
  }
  .appContainer(.preview)
}

#Preview("Active – Dark") {
  NavigationStack {
    FocusTimerView(
      viewModel: FocusTimerPreviewFactory.timerViewModel(
        session: FocusPreviewData.active,
        timerSnapshot: FocusPreviewData.activeTimerSnapshot
      ),
      onSessionEnded: {}
    )
    .preferredColorScheme(.dark)
  }
  .appContainer(.preview)
}

#Preview("Active – Accessibility Type") {
  NavigationStack {
    FocusTimerView(
      viewModel: FocusTimerPreviewFactory.timerViewModel(
        session: FocusPreviewData.paused,
        timerSnapshot: FocusPreviewData.pausedTimerSnapshot
      ),
      onSessionEnded: {}
    )
    .environment(\.dynamicTypeSize, .accessibility3)
  }
  .appContainer(.preview)
}
