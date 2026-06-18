//
//  CalmStateTransitionModifier.swift
//  FocusUp
//

import SwiftUI

extension View {
  /// Rest surfaces use the shared calm state transition.
  func calmStateTransition<ID: Hashable>(id: ID) -> some View {
    focusStateTransition(id: id)
  }
}
