//
//  FormDraftManager.swift
//  FocusUp
//

import Foundation

enum FormDraftManager {
  private static let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
  }()

  private static let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }()

  static func encode(_ draft: CreateTaskDraft) -> Data? {
    try? encoder.encode(draft)
  }

  static func decode(_ data: Data?) -> CreateTaskDraft? {
    guard let data, !data.isEmpty else { return nil }
    guard let draft = try? decoder.decode(CreateTaskDraft.self, from: data) else { return nil }
    if CreateTaskFormValidation.isDraftExpired(savedAt: draft.savedAt) {
      return nil
    }
    return draft
  }

  static func encodeEdit(_ draft: EditTaskDraft) -> Data? {
    try? encoder.encode(draft)
  }

  static func decodeEdit(_ data: Data?) -> EditTaskDraft? {
    guard let data, !data.isEmpty else { return nil }
    guard let draft = try? decoder.decode(EditTaskDraft.self, from: data) else { return nil }
    if CreateTaskFormValidation.isDraftExpired(savedAt: draft.form.savedAt) {
      return nil
    }
    return draft
  }
}
