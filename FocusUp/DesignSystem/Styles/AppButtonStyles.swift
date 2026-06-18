//
//  AppButtonStyles.swift
//  FocusUp
//

import SwiftUI

struct AppPrimaryButtonStyle: ButtonStyle {
  @Environment(\.focusMotionReduced) private var motionReduced
  @Environment(\.hapticsEnabled) private var hapticsEnabled
  @Environment(\.hapticFeedback) private var hapticFeedback

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(AppTypography.headline())
      .frame(maxWidth: .infinity, minHeight: AppSpacing.minimumTouchTarget)
      .padding(.horizontal, AppSpacing.md)
      .background(AppColors.focus.opacity(configuration.isPressed ? 0.85 : 1))
      .foregroundStyle(AppColors.onFocus)
      .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonRadius, style: .continuous))
      .animation(FocusMotion.animation(reduced: motionReduced, style: .quickPress), value: configuration.isPressed)
      .onChange(of: configuration.isPressed) { _, isPressed in
        guard isPressed, hapticsEnabled else { return }
        hapticFeedback.lightImpact()
      }
  }
}

struct AppSecondaryButtonStyle: ButtonStyle {
  @Environment(\.focusMotionReduced) private var motionReduced
  @Environment(\.hapticsEnabled) private var hapticsEnabled
  @Environment(\.hapticFeedback) private var hapticFeedback

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(AppTypography.headline())
      .frame(maxWidth: .infinity, minHeight: AppSpacing.minimumTouchTarget)
      .padding(.horizontal, AppSpacing.md)
      .background(AppColors.surface.opacity(configuration.isPressed ? 0.92 : 1))
      .foregroundStyle(AppColors.primaryText)
      .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonRadius, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: AppSpacing.buttonRadius, style: .continuous)
          .stroke(AppColors.separator, lineWidth: 1)
      )
      .animation(FocusMotion.animation(reduced: motionReduced, style: .quickPress), value: configuration.isPressed)
      .onChange(of: configuration.isPressed) { _, isPressed in
        guard isPressed, hapticsEnabled else { return }
        hapticFeedback.lightImpact()
      }
  }
}

struct AppDestructiveButtonStyle: ButtonStyle {
  @Environment(\.focusMotionReduced) private var motionReduced

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(AppTypography.headline())
      .frame(maxWidth: .infinity, minHeight: AppSpacing.minimumTouchTarget)
      .padding(.horizontal, AppSpacing.md)
      .background(AppColors.error.opacity(configuration.isPressed ? 0.85 : 1))
      .foregroundStyle(AppColors.onPrimary)
      .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonRadius, style: .continuous))
      .animation(FocusMotion.animation(reduced: motionReduced, style: .quickPress), value: configuration.isPressed)
  }
}

extension ButtonStyle where Self == AppPrimaryButtonStyle {
  static var appPrimary: AppPrimaryButtonStyle { AppPrimaryButtonStyle() }
}

extension ButtonStyle where Self == AppSecondaryButtonStyle {
  static var appSecondary: AppSecondaryButtonStyle { AppSecondaryButtonStyle() }
}

extension ButtonStyle where Self == AppDestructiveButtonStyle {
  static var appDestructive: AppDestructiveButtonStyle { AppDestructiveButtonStyle() }
}
