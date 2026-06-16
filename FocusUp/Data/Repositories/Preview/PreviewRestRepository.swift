//
//  PreviewRestRepository.swift
//  FocusUp
//

import Foundation

@MainActor
final class PreviewRestRepository: RestRepository {
  private var sessions: [RestSession] = RestPreviewData.all

  func fetchAll() async throws -> [RestSession] { sessions }

  func fetch(id: UUID) async throws -> RestSession? {
    sessions.first { $0.id == id }
  }

  func fetchActive() async throws -> RestSession? {
    sessions.first { $0.status.isActiveLifecycle }
  }

  func save(_ session: RestSession) async throws {
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
