//
//  SessionAmbientSoundCategory.swift
//  FocusUp
//

import Foundation

enum SessionAmbientSoundCategory: Equatable {
  case focus
  case rest

  /// Candidate bundle subdirectories (Xcode may flatten folder references differently).
  var resourceSubdirectories: [String] {
    switch self {
    case .focus:
      ["Sounds/focus_sounds", "focus_sounds"]
    case .rest:
      ["Sounds/rest_sounds", "rest_sounds"]
    }
  }
}
