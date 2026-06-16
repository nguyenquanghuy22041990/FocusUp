//
//  FocusMotion.swift
//  FocusUp
//

import SwiftUI

/// Calm, production-quality motion tokens shared across the app.
enum FocusMotion {
  enum Duration {
    static let instant: TimeInterval = 0.15
    static let quick: TimeInterval = 0.25
    static let standard: TimeInterval = 0.28
    static let progress: TimeInterval = 0.35
    static let breathing: TimeInterval = 4
  }

  static let springResponse: Double = 0.55
  static let springDamping: Double = 0.86
  static let breathingIntensity: CGFloat = 0.02

  enum Style: Equatable, Sendable {
    case quickPress
    case softFade
    case gentleSpring
    case progress
    case breathing
    case cardAppear
    case navigation
  }

  static var quickPress: Animation {
    .easeOut(duration: Duration.instant)
  }

  static var softFade: Animation {
    .easeInOut(duration: Duration.quick)
  }

  static var gentleSpring: Animation {
    .spring(response: springResponse, dampingFraction: springDamping)
  }

  static var progress: Animation {
    .easeInOut(duration: Duration.progress)
  }

  static var breathing: Animation {
    .easeInOut(duration: Duration.breathing).repeatForever(autoreverses: true)
  }

  static var cardAppear: Animation {
    .easeOut(duration: Duration.standard)
  }

  static var navigation: Animation {
    .easeInOut(duration: Duration.standard)
  }

  /// Returns `nil` when motion should be reduced so SwiftUI skips implicit animation.
  static func animation(reduced: Bool, style: Style) -> Animation? {
    guard !reduced else { return nil }
    switch style {
    case .quickPress: return quickPress
    case .softFade: return softFade
    case .gentleSpring: return gentleSpring
    case .progress: return progress
    case .breathing: return breathing
    case .cardAppear: return cardAppear
    case .navigation: return navigation
    }
  }
}
