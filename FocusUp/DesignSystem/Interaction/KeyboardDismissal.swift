//
//  KeyboardDismissal.swift
//  FocusUp
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

enum KeyboardDismissal {
  static func dismiss() {
    #if canImport(UIKit)
    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder),
      to: nil,
      from: nil,
      for: nil
    )
    #endif
  }
}

/// Scroll view that dismisses the keyboard when the user taps empty background (not controls).
struct KeyboardDismissibleScrollView<Content: View>: View {
  @ViewBuilder private let content: () -> Content

  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  var body: some View {
    GeometryReader { geometry in
      ScrollView {
        content()
          .frame(maxWidth: .infinity, alignment: .top)
          .frame(minHeight: geometry.size.height, alignment: .top)
          .contentShape(Rectangle())
          .onTapGesture { KeyboardDismissal.dismiss() }
      }
      .scrollDismissesKeyboard(.interactively)
      .scrollBounceBehavior(.basedOnSize)
    }
  }
}
