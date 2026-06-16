//
//  TaskRepository.swift
//  FocusUp
//

import Foundation

@MainActor
protocol TaskRepository {
  func fetchAll() async throws -> [Task]
  func fetch(id: UUID) async throws -> Task?
  func create(_ task: Task) async throws
  func update(_ task: Task) async throws
  func save(_ task: Task) async throws
  func updateMilestone(taskID: UUID, milestone: TaskMilestone) async throws
  func delete(id: UUID) async throws
}
