//
//  TasksRouteTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@Suite(.tags(.navigation, .production))
struct TasksRouteTests {
  @Test
  func idsAreStableForFilterCases() {
    #expect(TasksRoute.today.id == "today")
    #expect(TasksRoute.upcoming.id == "upcoming")
    #expect(TasksRoute.completed.id == "completed")
  }

  @Test
  func detailAndEditIdsIncludeTaskIdentifier() {
    let taskID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    #expect(TasksRoute.detail(taskID).id == taskID.uuidString)
    #expect(TasksRoute.edit(taskID).id == "edit-\(taskID.uuidString)")
  }

  @Test
  func titlesAndAccessibilityLabelsMatch() {
    #expect(TasksRoute.create.title == "New Task")
    #expect(TasksRoute.edit(UUID()).accessibilityLabel == TasksRoute.edit(UUID()).title)
    #expect(TasksRoute.filterCases == [.today, .upcoming, .completed])
  }
}
