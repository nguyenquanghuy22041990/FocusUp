//
//  PreviewSampleData.swift
//  FocusUp
//

import Foundation
import SwiftData

enum PreviewSampleData {
  @MainActor
  static func seed(into context: ModelContext) {
    let existing = (try? context.fetch(FetchDescriptor<TaskEntity>())) ?? []
    guard existing.isEmpty else { return }

    let task = TaskPreviewData.list[0]

    let session = FocusSession(
      title: "Morning Focus",
      plannedDurationSeconds: 25 * 60,
      elapsedSeconds: 12 * 60,
      status: .active,
      segmentStartedAt: .now.addingTimeInterval(-12 * 60),
      sessionStartedAt: .now.addingTimeInterval(-12 * 60)
    )

    let preferences = UserPreferences(
      prefersReducedMotion: false,
      voiceOverHintsEnabled: true,
      hapticsEnabled: true
    )

    _ = TaskMapper.toEntity(task, context: context)
    _ = FocusSessionMapper.toEntity(session, context: context)
    _ = UserPreferencesMapper.toEntity(preferences, context: context)

  try? context.save()
  }

  static var sampleTasks: [Task] {
    TaskPreviewData.list
  }

  static var sampleFocusSession: FocusSession {
    FocusPreviewData.planned
  }

  static var sampleStatistics: FocusStatisticsSummary {
    FocusStatisticsSummary(
      totalFocusMinutes: 125,
      completedSessionsCount: 6,
      currentStreakDays: 3
    )
  }

  static var samplePreferences: UserPreferences {
    UserPreferences()
  }
}
