//
//  PreviewFocusRepository.swift
//  FocusUp
//

import Foundation

@MainActor
final class PreviewFocusRepository: FocusRepository {
  private var sessions: [FocusSession] = FocusPreviewData.all

  func fetchAll() async throws -> [FocusSession] { sessions }

  func fetch(id: UUID) async throws -> FocusSession? {
    sessions.first { $0.id == id }
  }

  func fetchActive() async throws -> FocusSession? {
    sessions.first { $0.status.isActiveLifecycle }
  }

  func fetchCompleted() async throws -> [FocusSession] {
    sessions.filter { $0.status == .completed }
  }

  func fetchStatistics() async throws -> FocusStatistics {
    FocusPreviewData.statistics
  }

  func save(_ session: FocusSession) async throws {
    if let index = sessions.firstIndex(where: { $0.id == session.id }) {
      sessions[index] = session
    } else {
      sessions.append(session)
    }
  }

  func delete(id: UUID) async throws {
    sessions.removeAll { $0.id == id }
  }
}
