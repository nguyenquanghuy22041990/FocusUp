//
//  AppButton.swift
//  FocusUp
//

import SwiftUI

private struct AppButtonLabel: View {
  let title: String
  let isLoading: Bool
  var progressTint: Color = AppColors.onFocus

  var body: some View {
    ZStack {
      if isLoading {
        ProgressView()
          .tint(progressTint)
      } else {
        Text(title)
          .appMultilineText()
      }
    }
    .frame(maxWidth: .infinity)
    .frame(minHeight: AppSpacing.minimumTouchTarget)
    .focusMotionAnimation(isLoading, style: .softFade)
  }
}

struct PrimaryButton: View {
  let title: String
  var isLoading: Bool = false
  var isDisabled: Bool = false
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      AppButtonLabel(title: title, isLoading: isLoading)
    }
    .buttonStyle(.appPrimary)
    .disabled(isDisabled || isLoading)
    .accessibilityLabel(title)
    .accessibilityHint(isLoading ? "Loading" : "")
    .accessibilityAddTraits(isLoading ? .updatesFrequently : [])
  }
}

struct SecondaryButton: View {
  let title: String
  var isLoading: Bool = false
  var isDisabled: Bool = false
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      AppButtonLabel(title: title, isLoading: isLoading, progressTint: AppColors.focus)
    }
    .buttonStyle(.appSecondary)
    .disabled(isDisabled || isLoading)
    .accessibilityLabel(title)
  }
}

struct DestructiveButton: View {
  let title: String
  var isDisabled: Bool = false
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      AppButtonLabel(title: title, isLoading: false)
    }
    .buttonStyle(.appDestructive)
    .disabled(isDisabled)
    .accessibilityLabel(title)
    .accessibilityHint("Destructive action")
  }
}

struct LoadingButton: View {
  let title: String
  var isLoading: Bool
  var style: LoadingButtonStyle = .primary
  var isDisabled: Bool = false
  let action: () -> Void

  enum LoadingButtonStyle {
    case primary
    case secondary
  }

  var body: some View {
    switch style {
    case .primary:
      PrimaryButton(title: title, isLoading: isLoading, isDisabled: isDisabled, action: action)
    case .secondary:
      SecondaryButton(title: title, isLoading: isLoading, isDisabled: isDisabled, action: action)
    }
  }
}
