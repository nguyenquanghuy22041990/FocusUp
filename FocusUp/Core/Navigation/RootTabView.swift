//
//  RootTabView.swift
//  FocusUp
//

import SwiftUI

/// Backward-compatible entry that forwards to the adaptive navigation shell.
struct RootTabView: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        AdaptiveRootNavigationView(coordinator: coordinator)
    }
}

#Preview {
    RootTabView(coordinator: .preview)
        .appContainer(.preview)
}
