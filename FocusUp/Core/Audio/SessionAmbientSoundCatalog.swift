//
//  SessionAmbientSoundCatalog.swift
//  FocusUp
//

import Foundation

enum SessionAmbientSoundCatalog {
  static func randomURL(for category: SessionAmbientSoundCategory) -> URL? {
    allURLs(for: category).randomElement()
  }

  static func allURLs(for category: SessionAmbientSoundCategory) -> [URL] {
    for subdirectory in category.resourceSubdirectories {
      if let urls = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: subdirectory),
         !urls.isEmpty {
        return urls.sorted { $0.lastPathComponent < $1.lastPathComponent }
      }
    }
    return bundleRootURLs(for: category)
  }

  /// Xcode synchronized groups may copy mp3 files to the bundle root.
  private static func bundleRootURLs(for category: SessionAmbientSoundCategory) -> [URL] {
    let prefix = category == .focus ? "focused_sound_" : "relaxing_sound_"
    guard let resourceURL = Bundle.main.resourceURL,
          let contents = try? FileManager.default.contentsOfDirectory(
            at: resourceURL,
            includingPropertiesForKeys: nil
          ) else {
      return []
    }

    return contents
      .filter { url in
        url.pathExtension.lowercased() == "mp3"
          && url.deletingPathExtension().lastPathComponent.hasPrefix(prefix)
      }
      .sorted { $0.lastPathComponent < $1.lastPathComponent }
  }
}
