//
//  FocusMotionAccessibility.swift
//  FocusUp
//

import SwiftUI

/// Combines system Reduce Motion with the in-app preference.
enum FocusMotionPolicy {
  static func isReduced(systemReduceMotion: Bool, appPrefersReducedMotion: Bool) -> Bool {
    systemReduceMotion || appPrefersReducedMotion
  }
}

// MARK: - Environment

private struct AppPrefersReducedMotionKey: EnvironmentKey {
  static let defaultValue = false
}

private struct FocusMotionReducedKey: EnvironmentKey {
  static let defaultValue = false
}

private struct HapticsEnabledKey: EnvironmentKey {
  static let defaultValue = true
}

extension EnvironmentValues {
  /// User preference from persisted settings (set at app root).
  var appPrefersReducedMotion: Bool {
    get { self[AppPrefersReducedMotionKey.self] }
    set { self[AppPrefersReducedMotionKey.self] = newValue }
  }

  /// Effective reduced-motion flag (system OR app preference).
  var focusMotionReduced: Bool {
    get { self[FocusMotionReducedKey.self] }
    set { self[FocusMotionReducedKey.self] = newValue }
  }

  /// Whether haptic feedback is allowed for this session.
  var hapticsEnabled: Bool {
    get { self[HapticsEnabledKey.self] }
    set { self[HapticsEnabledKey.self] = newValue }
  }
}

/// Publishes `focusMotionReduced` by merging accessibility and app settings.
struct FocusMotionContextModifier: ViewModifier {
  @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
  let appPrefersReducedMotion: Bool

  func body(content: Content) -> some View {
    content
      .environment(\.appPrefersReducedMotion, appPrefersReducedMotion)
      .environment(
        \.focusMotionReduced,
        FocusMotionPolicy.isReduced(
          systemReduceMotion: accessibilityReduceMotion,
          appPrefersReducedMotion: appPrefersReducedMotion
        )
      )
  }
}

extension View {
  func focusMotionContext(appPrefersReducedMotion: Bool) -> some View {
    modifier(FocusMotionContextModifier(appPrefersReducedMotion: appPrefersReducedMotion))
  }
}
