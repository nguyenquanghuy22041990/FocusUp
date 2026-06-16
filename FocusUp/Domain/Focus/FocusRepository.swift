//
//  FocusRepository.swift
//  FocusUp
//

import Foundation

@MainActor
protocol FocusRepository {
  func fetchAll() async throws -> [FocusSession]
  func fetch(id: UUID) async throws -> FocusSession?
  func fetchActive() async throws -> FocusSession?
  func fetchCompleted() async throws -> [FocusSession]
  func fetchStatistics() async throws -> FocusStatistics
  func save(_ session: FocusSession) async throws
  func delete(id: UUID) async throws
}
