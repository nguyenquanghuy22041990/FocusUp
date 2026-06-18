//
//  PreviewSampleDataTests.swift
//  FocusUp
//

import Testing
@testable import FocusUp

struct PreviewSampleDataTests {
  @Test(.tags(.persistence))
  func previewTasksAreNonEmpty() {
    #expect(!PreviewSampleData.sampleTasks.isEmpty)
  }

  @Test(.tags(.persistence))
  func previewStatisticsHaveValues() {
    let summary = PreviewSampleData.sampleStatistics
    #expect(summary.totalFocusMinutes > 0)
    #expect(summary.completedSessionsCount > 0)
  }
}
