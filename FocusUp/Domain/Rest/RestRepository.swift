//
//  RestRepository.swift
//  FocusUp
//

import Foundation

@MainActor
protocol RestRepository {
  func fetchAll() async throws -> [RestSession]
  func fetch(id: UUID) async throws -> RestSession?
  func fetchActive() async throws -> RestSession?
  func save(_ session: RestSession) async throws
  func delete(id: UUID) async throws
}
