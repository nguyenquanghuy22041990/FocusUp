//
//  HapticFeedbackCoordinator.swift
//  FocusUp
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Lightweight, accessibility-conscious haptic feedback.
@MainActor
final class HapticFeedbackCoordinator {
  var isEnabled: Bool = true

  #if canImport(UIKit)
  private let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
  private let selectionGenerator = UISelectionFeedbackGenerator()
  private let notificationGenerator = UINotificationFeedbackGenerator()
  #endif

  func prepare() {
    #if canImport(UIKit)
    lightImpactGenerator.prepare()
    selectionGenerator.prepare()
    notificationGenerator.prepare()
    #endif
  }

  func lightImpact() {
    guard isEnabled else { return }
    #if canImport(UIKit)
    lightImpactGenerator.impactOccurred(intensity: 0.55)
    #endif
  }

  func selectionChanged() {
    guard isEnabled else { return }
    #if canImport(UIKit)
    selectionGenerator.selectionChanged()
    #endif
  }

  func success() {
    guard isEnabled else { return }
    #if canImport(UIKit)
    notificationGenerator.notificationOccurred(.success)
    #endif
  }

  func warning() {
    guard isEnabled else { return }
    #if canImport(UIKit)
    notificationGenerator.notificationOccurred(.warning)
    #endif
  }

  func sessionCompleted() {
    success()
  }

  func taskCompleted() {
    success()
  }
}

// MARK: - Environment

private struct HapticFeedbackCoordinatorKey: EnvironmentKey {
  @MainActor static let defaultValue = HapticFeedbackCoordinator()
}

extension EnvironmentValues {
  var hapticFeedback: HapticFeedbackCoordinator {
    get { self[HapticFeedbackCoordinatorKey.self] }
    set { self[HapticFeedbackCoordinatorKey.self] = newValue }
  }
}

extension View {
  func hapticFeedback(_ coordinator: HapticFeedbackCoordinator) -> some View {
    environment(\.hapticFeedback, coordinator)
  }
}
