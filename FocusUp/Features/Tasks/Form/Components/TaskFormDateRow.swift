//
//  TaskFormDateRow.swift
//  FocusUp
//

import SwiftUI

struct TaskFormDateRow: View {
  let label: String
  @Binding var date: Date?
  var errorMessage: String?

  var body: some View {
    VStack(alignment: .leading, spacing: AppSpacing.xs) {
      Text(label)
        .appFont(.callout)
        .foregroundStyle(AppColors.secondaryText)

      Toggle("Set deadline", isOn: hasDeadlineBinding)
        .appFont(.body)
        .frame(minHeight: AppSpacing.minimumTouchTarget)

      if date != nil {
        DatePicker(
          "Deadline date",
          selection: deadlineBinding,
          in: Calendar.current.startOfDay(for: .now)...,
          displayedComponents: [.date]
        )
        .datePickerStyle(.compact)
        .labelsHidden()
        .frame(minHeight: AppSpacing.minimumTouchTarget)
        .accessibilityLabel("Deadline date")
      }

      if let errorMessage {
        Text(errorMessage)
          .appFont(.caption)
          .foregroundStyle(AppColors.error)
      }
    }
  }

  private var hasDeadlineBinding: Binding<Bool> {
    Binding(
      get: { date != nil },
      set: { enabled in
        if enabled {
          date = Calendar.current.startOfDay(for: .now)
        } else {
          date = nil
        }
      }
    )
  }

  private var deadlineBinding: Binding<Date> {
    Binding(
      get: {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        guard let date else { return startOfToday }
        let deadlineDay = calendar.startOfDay(for: date)
        return deadlineDay < startOfToday ? startOfToday : deadlineDay
      },
      set: { date = Calendar.current.startOfDay(for: $0) }
    )
  }
}
