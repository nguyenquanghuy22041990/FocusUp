//
//  ActivityAuthorizationService.swift
//  FocusUp
//

import Foundation

#if canImport(ActivityKit)
import ActivityKit
#endif

enum ActivityAuthorizationService {
  static var areActivitiesEnabled: Bool {
    #if canImport(ActivityKit)
    return ActivityAuthorizationInfo().areActivitiesEnabled
    #else
    return false
    #endif
  }
}
