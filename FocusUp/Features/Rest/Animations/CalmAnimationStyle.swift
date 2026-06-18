//
//  CalmAnimationStyle.swift
//  FocusUp
//

import SwiftUI

/// Rest-specific aliases over the global motion language.
enum CalmAnimationStyle {
  static let breathingDuration = FocusMotion.Duration.breathing
  static let transitionResponse = FocusMotion.springResponse
  static let transitionDamping = FocusMotion.springDamping

  static var breathing: Animation { FocusMotion.breathing }
  static var gentleSpring: Animation { FocusMotion.gentleSpring }
  static var softFade: Animation { FocusMotion.progress }
}
