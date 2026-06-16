//
//  FocusMotionTests.swift
//  FocusUpTests
//

import Foundation
import Testing
@testable import FocusUp

struct FocusMotionPolicyTests {
  @Test(.tags(.designSystem, .motion))
  func reducedMotionWhenSystemOrAppPreferenceEnabled() {
    #expect(FocusMotionPolicy.isReduced(systemReduceMotion: false, appPrefersReducedMotion: false) == false)
    #expect(FocusMotionPolicy.isReduced(systemReduceMotion: true, appPrefersReducedMotion: false) == true)
    #expect(FocusMotionPolicy.isReduced(systemReduceMotion: false, appPrefersReducedMotion: true) == true)
    #expect(FocusMotionPolicy.isReduced(systemReduceMotion: true, appPrefersReducedMotion: true) == true)
  }
}

struct FocusMotionAnimationTests {
  @Test(.tags(.designSystem, .motion))
  func animationNilWhenReduced() {
    #expect(FocusMotion.animation(reduced: true, style: .progress) == nil)
    #expect(FocusMotion.animation(reduced: true, style: .gentleSpring) == nil)
  }

  @Test(.tags(.designSystem, .motion))
  func animationPresentWhenNotReduced() {
    #expect(FocusMotion.animation(reduced: false, style: .progress) != nil)
    #expect(FocusMotion.animation(reduced: false, style: .navigation) != nil)
  }

  @Test(.tags(.designSystem, .motion))
  func calmTokensAlignWithGlobalMotion() {
    #expect(CalmAnimationStyle.transitionResponse == FocusMotion.springResponse)
    #expect(CalmAnimationStyle.breathingDuration == FocusMotion.Duration.breathing)
  }
}

struct HapticFeedbackCoordinatorTests {
  @Test(.tags(.designSystem, .motion))
  @MainActor
  func hapticsSkippedWhenDisabled() {
    let coordinator = HapticFeedbackCoordinator()
    coordinator.isEnabled = false
    coordinator.lightImpact()
    coordinator.success()
    coordinator.sessionCompleted()
    coordinator.taskCompleted()
    #expect(coordinator.isEnabled == false)
  }

  @Test(.tags(.designSystem, .motion))
  @MainActor
  func hapticsFireWhenEnabled() {
    let coordinator = HapticFeedbackCoordinator()
    coordinator.isEnabled = true
    coordinator.prepare()
    coordinator.lightImpact()
    coordinator.selectionChanged()
    coordinator.success()
    #expect(coordinator.isEnabled == true)
  }
}
