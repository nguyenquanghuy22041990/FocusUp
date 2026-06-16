//
//  LiveActivityManager.swift
//  FocusUp
//

import Foundation

#if canImport(ActivityKit)
import ActivityKit
#endif

@MainActor
final class LiveActivityManager: LiveActivityManaging {
  #if canImport(ActivityKit)
  private var activity: Activity<FocusSessionAttributes>?
  private var trackedSessionID: UUID?
  #endif

  func startFocus(session: FocusSession, now: Date = .now) async {
    await start(
      sessionType: .focus,
      sessionID: session.id,
      title: session.title,
      startDate: session.sessionStartedAt ?? now,
      totalDurationSeconds: session.plannedDurationSeconds,
      mapped: ActivityStateMapper.mapFocus(session, now: now)
    )
  }

  func startRest(session: RestSession, now: Date = .now) async {
    await start(
      sessionType: .rest,
      sessionID: session.id,
      title: "Rest Break",
      startDate: session.sessionStartedAt ?? now,
      totalDurationSeconds: session.plannedDurationSeconds,
      mapped: ActivityStateMapper.mapRest(session, now: now)
    )
  }

  func syncFocus(session: FocusSession, now: Date = .now) async {
    await sync(
      sessionID: session.id,
      mapped: ActivityStateMapper.mapFocus(session, now: now),
      motivation: SessionLiveActivityType.focus.defaultMotivation
    )
  }

  func syncRest(session: RestSession, now: Date = .now) async {
    await sync(
      sessionID: session.id,
      mapped: ActivityStateMapper.mapRest(session, now: now),
      motivation: SessionLiveActivityType.rest.defaultMotivation
    )
  }

  func end(immediate: Bool = false) async {
    #if canImport(ActivityKit)
    let policy: ActivityUIDismissalPolicy = immediate
      ? .immediate
      : .after(.now + 4)
    let activities = Activity<FocusSessionAttributes>.activities
    guard !activities.isEmpty else {
      activity = nil
      trackedSessionID = nil
      return
    }

    for active in activities {
      let finalState = FocusSessionAttributes.ContentState(
        endDate: nil,
        pausedRemainingSeconds: nil,
        sessionState: .completed,
        progress: 1,
        motivationalMessage: active.attributes.sessionType.defaultMotivation
      )
      await active.end(
        ActivityContent(state: finalState, staleDate: nil),
        dismissalPolicy: policy
      )
    }
    activity = nil
    trackedSessionID = nil
    #endif
  }

  // MARK: - Private


  #if canImport(ActivityKit)
  private func start(
    sessionType: SessionLiveActivityType,
    sessionID: UUID,
    title: String,
    startDate: Date,
    totalDurationSeconds: Int,
    mapped: (
      state: LiveActivitySessionState,
      endDate: Date?,
      pausedRemainingSeconds: Int?,
      progress: Double
    )
  ) async {
    guard ActivityAuthorizationService.areActivitiesEnabled else { return }

    if trackedSessionID != sessionID {
      await end(immediate: true)
    }

    let attributes = FocusSessionAttributes(
      sessionType: sessionType,
      sessionTitle: title,
      sessionID: sessionID,
      startDate: startDate,
      totalDurationSeconds: totalDurationSeconds
    )

    let contentState = makeContentState(
      mapped: mapped,
      motivation: sessionType.defaultMotivation
    )

    do {
      let requested = try Activity.request(
        attributes: attributes,
        content: activityContent(for: contentState, mapped: mapped),
        pushType: nil
      )
      activity = requested
      trackedSessionID = sessionID
    } catch {
      // Live Activities are best-effort; session timer remains authoritative.
    }
  }

  private func sync(
    sessionID: UUID,
    mapped: (
      state: LiveActivitySessionState,
      endDate: Date?,
      pausedRemainingSeconds: Int?,
      progress: Double
    ),
    motivation: String
  ) async {
    guard ActivityAuthorizationService.areActivitiesEnabled else { return }

    #if canImport(ActivityKit)
    guard let activity, trackedSessionID == sessionID else { return }

    let contentState = makeContentState(mapped: mapped, motivation: motivation)
    await activity.update(activityContent(for: contentState, mapped: mapped))
    #endif
  }

  private func activityContent(
    for state: FocusSessionAttributes.ContentState,
    mapped: (
      state: LiveActivitySessionState,
      endDate: Date?,
      pausedRemainingSeconds: Int?,
      progress: Double
    )
  ) -> ActivityContent<FocusSessionAttributes.ContentState> {
    ActivityContent(state: state, staleDate: mapped.endDate)
  }

  private func makeContentState(
    mapped: (
      state: LiveActivitySessionState,
      endDate: Date?,
      pausedRemainingSeconds: Int?,
      progress: Double
    ),
    motivation: String
  ) -> FocusSessionAttributes.ContentState {
    FocusSessionAttributes.ContentState(
      endDate: mapped.endDate,
      pausedRemainingSeconds: mapped.pausedRemainingSeconds,
      sessionState: mapped.state,
      progress: mapped.progress,
      motivationalMessage: motivation
    )
  }
  #endif
}
