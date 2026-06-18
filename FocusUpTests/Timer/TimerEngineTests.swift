//
//  TimerEngineTests.swift
//  FocusUp
//

import Foundation
import Testing
@testable import FocusUp

@MainActor
struct TimerEngineTests {
  private func makeEngine(
    duration: Int = 100,
    clock: TestClock = TestClock()
  ) -> (TimerEngine, TestClock) {
    let engine = TimerEngine(
      configuration: TimerConfiguration(totalDurationSeconds: duration),
      clock: clock
    )
    return (engine, clock)
  }

  @Test(.tags(.foundation))
  func startTracksElapsedFromTimestamp() {
    let clock = TestClock()
    let (engine, _) = makeEngine(duration: 60, clock: clock)

    engine.start()
    clock.advance(by: 10)

    #expect(engine.state == .running)
    #expect(engine.elapsedSeconds() == 10)
    #expect(engine.remainingSeconds() == 50)
  }

  @Test(.tags(.foundation))
  func pauseFreezesElapsed() {
    let clock = TestClock()
    let (engine, _) = makeEngine(duration: 60, clock: clock)

    engine.start()
    clock.advance(by: 15)
    engine.pause()
    clock.advance(by: 30)

    #expect(engine.state == .paused)
    #expect(engine.elapsedSeconds() == 15)
    #expect(engine.remainingSeconds() == 45)
  }

  @Test(.tags(.foundation))
  func resumeContinuesFromPausedElapsed() {
    let clock = TestClock()
    let (engine, _) = makeEngine(duration: 60, clock: clock)

    engine.start()
    clock.advance(by: 10)
    engine.pause()
    clock.advance(by: 5)
    engine.resume()
    clock.advance(by: 8)

    #expect(engine.elapsedSeconds() == 18)
  }

  @Test(.tags(.foundation))
  func stopCompletesWhenDurationReached() {
    let clock = TestClock()
    let (engine, _) = makeEngine(duration: 20, clock: clock)

    engine.start()
    clock.advance(by: 25)
    let didComplete = engine.stop()

    #expect(didComplete)
    #expect(engine.state == .completed)
    #expect(engine.elapsedSeconds() == 20)
  }

  @Test(.tags(.foundation))
  func tickAutoCompletesRunningTimer() {
    let clock = TestClock()
    let (engine, _) = makeEngine(duration: 10, clock: clock)

    engine.start()
    clock.advance(by: 12)
    engine.tick()

    #expect(engine.state == .completed)
  }

  @Test(.tags(.foundation))
  func restoreReconcilesRunningElapsed() {
    let clock = TestClock(startingAt: Date(timeIntervalSince1970: 2_000_000))
    let (engine, _) = makeEngine(duration: 100, clock: clock)

    engine.start()
    let exported = engine.exportSnapshot()
    clock.advance(by: 20)

    engine.restore(from: exported)
    engine.reconcileAfterRestore()

    #expect(engine.elapsedSeconds() == 20)
  }
}
