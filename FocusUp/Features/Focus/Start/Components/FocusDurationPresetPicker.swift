//
//  FocusDurationPresetPicker.swift
//  FocusUp
//

import SwiftUI

struct FocusDurationPresetPicker: View {
  @Binding var selection: FocusDurationPreset
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
      Text("Duration")
        .appFont(.headline)
        .foregroundStyle(AppColors.primaryText)

      presetLayout
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel("Focus duration")
  }

  @ViewBuilder
  private var presetLayout: some View {
    let layout = dynamicTypeSize.isAccessibilitySize
      ? AnyLayout(VStackLayout(alignment: .leading, spacing: AppSpacing.sm))
      : AnyLayout(HStackLayout(spacing: AppSpacing.sm))

    layout {
      ForEach(FocusDurationPreset.allCases) { preset in
        presetButton(preset)
      }
    }
  }

  private func presetButton(_ preset: FocusDurationPreset) -> some View {
    let isSelected = selection == preset

    return Button {
      selection = preset
    } label: {
      Text(preset.label)
        .appFont(.callout)
        .frame(maxWidth: .infinity)
        .frame(minHeight: AppSpacing.minimumTouchTarget)
        .background(isSelected ? AppColors.focus.opacity(0.18) : AppColors.surfaceElevated)
        .foregroundStyle(isSelected ? AppColors.focus : AppColors.primaryText)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonRadius, style: .continuous))
        .overlay {
          RoundedRectangle(cornerRadius: AppSpacing.buttonRadius, style: .continuous)
            .stroke(isSelected ? AppColors.focus : .clear, lineWidth: 2)
        }
    }
    .buttonStyle(.plain)
    .accessibilityLabel(preset.accessibilityLabel)
    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
  }
}

private extension DynamicTypeSize {
  var isAccessibilitySize: Bool {
    switch self {
    case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
      true
    default:
      false
    }
  }
}
