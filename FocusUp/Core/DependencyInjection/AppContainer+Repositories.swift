//
//  AppContainer+Repositories.swift
//  FocusUp
//

import SwiftData
import SwiftUI

extension AppContainer {
  struct Repositories {
    let taskRepository: any TaskRepository
    let focusRepository: any FocusRepository
    let restRepository: any RestRepository
    let statisticsRepository: any StatisticsRepository
    let userPreferencesRepository: any UserPreferencesRepository

    @MainActor
    static func live(using persistence: PersistenceController) -> Repositories {
      let context = persistence.mainContext
      return Repositories(
        taskRepository: TaskRepositoryImpl(context: context),
        focusRepository: FocusRepositoryImpl(context: context),
        restRepository: RestRepositoryImpl(context: context),
        statisticsRepository: StatisticsRepositoryImpl(context: context),
        userPreferencesRepository: UserPreferencesRepositoryImpl(context: context)
      )
    }

    @MainActor
    static var preview: Repositories {
      Repositories(
        taskRepository: PreviewTaskRepository(),
        focusRepository: PreviewFocusRepository(),
        restRepository: PreviewRestRepository(),
        statisticsRepository: PreviewStatisticsRepository(),
        userPreferencesRepository: PreviewUserPreferencesRepository()
      )
    }

    @MainActor
    static func testing(using persistence: PersistenceController) -> Repositories {
      live(using: persistence)
    }
  }
}
