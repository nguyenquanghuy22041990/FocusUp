//
//  NavigationBackLockModifier.swift
//  FocusUp
//

import SwiftUI
import UIKit

/// Hides the back button and disables the interactive pop gesture when navigation should be locked.
struct NavigationBackLockModifier: ViewModifier {
  let isLocked: Bool

  func body(content: Content) -> some View {
    content
      .navigationBarBackButtonHidden(isLocked)
      .background {
        InteractivePopGestureDisabler(isPopEnabled: !isLocked)
      }
  }
}

extension View {
  func navigationBackLocked(_ isLocked: Bool) -> some View {
    modifier(NavigationBackLockModifier(isLocked: isLocked))
  }
}

private struct InteractivePopGestureDisabler: UIViewControllerRepresentable {
  let isPopEnabled: Bool

  func makeUIViewController(context: Context) -> UIViewController {
    UIViewController()
  }

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    DispatchQueue.main.async {
      uiViewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = isPopEnabled
    }
  }
}
