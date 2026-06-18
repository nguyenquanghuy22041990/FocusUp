//
//  FocusTimerViewModelTests.swift
//  FocusUp
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct FocusTimerViewModelTests {
  private func makeHarness(
    duration: Int = 120
  ) async throws -> (FocusTimerViewModel, FocusSessionManager, TestClock) {
    let persistence = try PersistenceController(inMemory: true)
    let repository = FocusRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()
    let manager = FocusSessionManager(
      repository: repository,
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )
    let viewModel = FocusTimerViewModel(
      sessionManager: manager,
      taskRepository: MockTaskRepository()
    )

    try await manager.startSession(title: "Deep Work", durationSeconds: duration)
    return (viewModel, manager, clock)
  }

  @Test(.tags(.focus))
  func progressAndRemainingUseTimerEngine() async throws {
    let (viewModel, _, clock) = try await makeHarness(duration: 100)
    clock.advance(by: 25)

    await viewModel.advanceTimerTick()

    #expect(viewModel.remainingSeconds(at: clock.now()) == 75)
    #expect(viewModel.progress(at: clock.now()) == 0.25)
    #expect(viewModel.remainingLabel(at: clock.now()) == "1:15")
  }

  @Test(.tags(.focus))
  func pauseAndResumeUpdatesInteractionState() async throws {
    let (viewModel, _, clock) = try await makeHarness()
    clock.advance(by: 10)

    await viewModel.pause()
    #expect(viewModel.interactionState == .paused)

    clock.advance(by: 5)
    await viewModel.resume()
    #expect(viewModel.interactionState == .running)

    clock.advance(by: 3)
    await viewModel.advanceTimerTick()
    #expect(viewModel.remainingSeconds(at: clock.now()) == 120 - 13)
  }

  @Test(.tags(.focus, .production))
  func autoCompleteTickClearsSessionAndShowsBanner() async throws {
    let (viewModel, manager, clock) = try await makeHarness(duration: 20)

    clock.advance(by: 25)
    await viewModel.advanceTimerTick()

    #expect(manager.activeSession == nil)
    #expect(viewModel.showCompletionBanner)
    #expect(viewModel.interactionState == .completed)
    #expect(!viewModel.locksBackNavigation)
  }

  @Test(.tags(.focus))
  func completeClearsActiveSession() async throws {
    let (viewModel, manager, _) = try await makeHarness()

    let success = await viewModel.complete()

    #expect(success)
    #expect(manager.activeSession == nil)
    #expect(viewModel.showCompletionBanner)
    #expect(viewModel.interactionState == .completed)
  }

  @Test(.tags(.focus))
  func restorationSyncReflectsPausedSession() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let repository = FocusRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()
    let manager = FocusSessionManager(
      repository: repository,
      clock: clock,
      ambientSoundPlayer: NoOpSessionAmbientSoundPlayer()
    )

    try await manager.startSession(title: "Restore UI", durationSeconds: 60)
    clock.advance(by: 20)
    try await manager.pauseSession()

    let viewModel = FocusTimerViewModel(
      sessionManager: manager,
      taskRepository: MockTaskRepository()
    )
    #expect(viewModel.interactionState == .paused)
    #expect(viewModel.remainingSeconds(at: clock.now()) == 40)
    #expect(viewModel.statusAccessibilityLabel == "Paused")
  }

  @Test(.tags(.focus))
  func accessibilityDescriptionsUseSessionTiming() async throws {
    let (viewModel, _, clock) = try await makeHarness(duration: 60)
    clock.advance(by: 10)

    let elapsed = viewModel.elapsedAccessibilityDescription(at: clock.now())
    let remaining = viewModel.remainingAccessibilityDescription(at: clock.now())

    #expect(elapsed.contains("10"))
    #expect(remaining.contains("50"))
  }
}
