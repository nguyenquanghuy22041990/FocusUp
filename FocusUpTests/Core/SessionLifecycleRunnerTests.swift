//
//  SessionLifecycleRunnerTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct SessionLifecycleRunnerTests {
  private func makeRunner() throws -> (SessionLifecycleRunner<FocusSession>, TestClock, FocusRepositoryImpl) {
    let persistence = try PersistenceController(inMemory: true)
    let repository = FocusRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()
    let runner = SessionLifecycleRunner(
      clock: clock,
      store: SessionLifecycleStore(
        fetchActive: { try await repository.fetchActive() },
        fetch: { try await repository.fetch(id: $0) },
        save: { try await repository.save($0) }
      )
    )
    return (runner, clock, repository)
  }

  @Test(.tags(.foundation))
  func activatePauseResumeCompleteLifecycle() async throws {
    let (runner, clock, repository) = try makeRunner()
    let now = clock.now()
    let session = FocusSession(
      title: "Deep Work",
      plannedDurationSeconds: 60,
      elapsedSeconds: 0,
      status: .active,
      segmentStartedAt: now,
      sessionStartedAt: now
    )

    try await runner.activateNewSession(session, durationSeconds: 60)
    #expect(runner.activeSession?.status == .active)

    clock.advance(by: 10)
    try await runner.pauseSession()
    #expect(runner.activeSession?.status == .paused)
    #expect(runner.activeSession?.elapsedSeconds == 10)

    clock.advance(by: 5)
    try await runner.resumeSession()
    clock.advance(by: 7)
    #expect(runner.timerEngine.elapsedSeconds() == 17)

    try await runner.completeSession()
    #expect(runner.activeSession == nil)
    #expect(try await repository.fetchActive() == nil)

    let completed = try await repository.fetchCompleted()
    #expect(completed.count == 1)
    #expect(completed.first?.status == .completed)
  }

  @Test(.tags(.foundation))
  func tickAutoCompletesWhenTimerExpires() async throws {
    let (runner, clock, repository) = try makeRunner()
    let now = clock.now()
    let session = FocusSession(
      title: "Auto",
      plannedDurationSeconds: 30,
      elapsedSeconds: 0,
      status: .active,
      segmentStartedAt: now,
      sessionStartedAt: now
    )
    try await runner.activateNewSession(session, durationSeconds: 30)

    clock.advance(by: 30)
    let snapshot = await runner.tick()
    #expect(snapshot.state == .completed)
    #expect(runner.activeSession == nil)
    #expect(try await repository.fetchCompleted().count == 1)
  }

  @Test(.tags(.foundation))
  func restoreOnLaunchRebuildsActiveSession() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let repository = FocusRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()

    var session = DomainFixtures.focusSession(title: "Restore", status: .active)
    session.elapsedSeconds = 12
    session.segmentStartedAt = clock.now()
    session.sessionStartedAt = clock.now()
    try await repository.save(session)

    let runner = SessionLifecycleRunner(
      clock: clock,
      store: SessionLifecycleStore(
        fetchActive: { try await repository.fetchActive() },
        fetch: { try await repository.fetch(id: $0) },
        save: { try await repository.save($0) }
      )
    )
    await runner.restoreOnLaunch()

    #expect(runner.activeSession?.id == session.id)
    clock.advance(by: 8)
    #expect(runner.timerEngine.elapsedSeconds() == 20)
  }

  @Test(.tags(.foundation))
  func activateFailsWhenSessionAlreadyActive() async throws {
    let (runner, clock, _) = try makeRunner()
    let now = clock.now()
    let session = FocusSession(
      title: "One",
      plannedDurationSeconds: 60,
      elapsedSeconds: 0,
      status: .active,
      segmentStartedAt: now,
      sessionStartedAt: now
    )
    try await runner.activateNewSession(session, durationSeconds: 60)

    let duplicate = FocusSession(
      title: "Two",
      plannedDurationSeconds: 60,
      elapsedSeconds: 0,
      status: .active,
      segmentStartedAt: now,
      sessionStartedAt: now
    )
    await #expect(throws: SessionLifecycleError.sessionAlreadyActive) {
      try await runner.activateNewSession(duplicate, durationSeconds: 60)
    }
  }

  @Test(.tags(.rest))
  func restSessionRunnerLifecycle() async throws {
    let persistence = try PersistenceController(inMemory: true)
    let repository = RestRepositoryImpl(context: persistence.mainContext)
    let clock = TestClock()
    let runner = SessionLifecycleRunner(
      clock: clock,
      store: SessionLifecycleStore(
        fetchActive: { try await repository.fetchActive() },
        fetch: { try await repository.fetch(id: $0) },
        save: { try await repository.save($0) }
      )
    )

    let now = clock.now()
    let session = RestSession(
      plannedDurationSeconds: 45,
      elapsedSeconds: 0,
      status: .active,
      segmentStartedAt: now,
      sessionStartedAt: now
    )
    try await runner.activateNewSession(session, durationSeconds: 45)
    clock.advance(by: 15)
    try await runner.pauseSession()
    try await runner.resumeSession()
    clock.advance(by: 10)
    try await runner.completeSession()

    #expect(runner.activeSession == nil)
    #expect(try await repository.fetchActive() == nil)
  }
}
