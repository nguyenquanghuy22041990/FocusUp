//
//  AppRestorationStore.swift
//  FocusUp
//

import Foundation

/// App-wide restoration backups that survive force quit (unlike SceneStorage alone).
enum AppRestorationStore {
  private enum Keys {
    static let navigation = "focusup.restoration.navigation"
    static let focusTimer = "focusup.restoration.timer.focus"
    static let restTimer = "focusup.restoration.timer.rest"
    static let createTaskDraft = "focusup.restoration.form.createTask"
  }

  static func saveNavigation(_ state: PersistedNavigationState) {
    guard let data = NavigationRestorationManager.encode(state) else { return }
    UserDefaults.standard.set(data, forKey: Keys.navigation)
  }

  static func loadNavigation() -> PersistedNavigationState? {
    guard let data = UserDefaults.standard.data(forKey: Keys.navigation) else { return nil }
    return NavigationRestorationManager.decode(data)
  }

  static func saveFocusTimerSnapshot(_ data: Data?) {
    if let data {
      UserDefaults.standard.set(data, forKey: Keys.focusTimer)
    } else {
      UserDefaults.standard.removeObject(forKey: Keys.focusTimer)
    }
  }

  static func loadFocusTimerSnapshot() -> Data? {
    UserDefaults.standard.data(forKey: Keys.focusTimer)
  }

  static func saveRestTimerSnapshot(_ data: Data?) {
    if let data {
      UserDefaults.standard.set(data, forKey: Keys.restTimer)
    } else {
      UserDefaults.standard.removeObject(forKey: Keys.restTimer)
    }
  }

  static func loadRestTimerSnapshot() -> Data? {
    UserDefaults.standard.data(forKey: Keys.restTimer)
  }

  static func saveCreateTaskDraft(_ data: Data?) {
    if let data {
      UserDefaults.standard.set(data, forKey: Keys.createTaskDraft)
    } else {
      UserDefaults.standard.removeObject(forKey: Keys.createTaskDraft)
    }
  }

  static func loadCreateTaskDraft() -> Data? {
    UserDefaults.standard.data(forKey: Keys.createTaskDraft)
  }
}
