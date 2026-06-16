//
//  RestTimerViewModelTests.swift
//  FocusUp
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct RestTimerViewModelTests {
  private func makeHarness(duration: Int = 90) async throws -> (RestTimerViewModel, RestSessionManager, TestClock) {
    let persistence = try PersistenceController(inMemory: true)
    let repository = RestRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()
    let manager = RestSessionManager(
      repository: repository,
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    let viewModel = RestTimerViewModel(sessionManager: manager)

    try await manager.startSession(durationSeconds: duration)
    return (viewModel, manager, clock)
  }

  @Test(.tags(.rest))
  func setupStateBeforeSession() throws {
    let persistence = try PersistenceController(inMemory: true)
    let manager = RestSessionManager(
      repository: RestRepositoryImpl(context: persistence.mainContext),
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    let viewModel = RestTimerViewModel(sessionManager: manager)

    #expect(viewModel.interactionState == .setup)
    #expect(viewModel.animationPhase == .setup)
    #expect(viewModel.canStart)
  }

  @Test(.tags(.rest))
  func startSessionTransitionsToRunning() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let manager = RestSessionManager(
      repository: RestRepositoryImpl(context: persistence.mainContext),
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    let viewModel = RestTimerViewModel(sessionManager: manager)
    viewModel.selectedPreset = .thirty

    let started = await viewModel.startSession()

    #expect(started)
    #expect(viewModel.interactionState == .running)
    #expect(viewModel.animationPhase == .active)
    #expect(manager.activeSession?.plannedDurationSeconds == 30 * 60)
  }

  @Test(.tags(.rest))
  func pauseResumeAndProgress() async throws {
    let (viewModel, _, clock) = try await makeHarness()
    clock.advance(by: 20)

    await viewModel.pause()
    #expect(viewModel.interactionState == .paused)
    #expect(viewModel.animationPhase == .paused)

    clock.advance(by: 10)
    await viewModel.resume()
    clock.advance(by: 5)
    await viewModel.advanceTimerTick()

    #expect(viewModel.remainingSeconds(at: clock.now()) == 90 - 25)
  }

  @Test(.tags(.rest, .production))
  func autoCompleteTickClearsSessionAndShowsBanner() async throws {
    let (viewModel, manager, clock) = try await makeHarness(duration: 20)

    clock.advance(by: 25)
    await viewModel.advanceTimerTick()

    #expect(manager.activeSession == nil)
    #expect(viewModel.showCompletionBanner)
    #expect(viewModel.interactionState == .completed)
    #expect(!viewModel.locksBackNavigation)
  }

  @Test(.tags(.rest))
  func locksBackNavigationDuringActiveSession() async throws {
    let (viewModel, _, _) = try await makeHarness()
    #expect(viewModel.locksBackNavigation)

    _ = await viewModel.complete()
    #expect(!viewModel.locksBackNavigation)
  }

  @Test(.tags(.rest))
  func reducedMotionUsesStaticAnimationPhase() async throws {
    let (viewModel, _, _) = try await makeHarness()
    await viewModel.pause()
    #expect(viewModel.animationPhase == .paused)
    #expect(viewModel.statusAccessibilityLabel == "Rest paused")
  }
}
