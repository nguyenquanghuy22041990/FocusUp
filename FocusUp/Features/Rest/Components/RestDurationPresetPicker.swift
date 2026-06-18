//
//  RestDurationPresetPicker.swift
//  FocusUp
//

import SwiftUI

struct RestDurationPresetPicker: View {
  @Binding var selection: FocusDurationPreset
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  var body: some View {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
      Text("Rest duration")
        .appFont(.headline)
        .foregroundStyle(AppColors.primaryText)

      let layout = dynamicTypeSize.isAccessibilitySize
        ? AnyLayout(VStackLayout(alignment: .leading, spacing: AppSpacing.sm))
        : AnyLayout(HStackLayout(spacing: AppSpacing.sm))

      layout {
        ForEach(FocusDurationPreset.allCases) { preset in
          presetButton(preset)
        }
      }
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel("Rest duration")
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
        .background(isSelected ? AppColors.rest.opacity(0.18) : AppColors.surfaceElevated)
        .foregroundStyle(isSelected ? AppColors.rest : AppColors.primaryText)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonRadius, style: .continuous))
        .overlay {
          RoundedRectangle(cornerRadius: AppSpacing.buttonRadius, style: .continuous)
            .stroke(isSelected ? AppColors.rest : .clear, lineWidth: 2)
        }
    }
    .buttonStyle(.plain)
    .accessibilityLabel(preset.accessibilityLabel)
    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
  }
}
