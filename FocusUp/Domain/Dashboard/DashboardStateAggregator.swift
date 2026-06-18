//
//  DashboardStateAggregator.swift
//  FocusUp
//

import Foundation

/// Pure aggregation of dashboard presentation state from existing domain inputs.
enum DashboardStateAggregator {
  static func buildSnapshot(
    statistics: StatisticsSummary,
    tasks: [Task],
    activeFocus: FocusSession?,
    activeRest: Bool,
    now: Date = .now,
    calendar: Calendar = .current
  ) -> DashboardSnapshot {
    let todayMinutes = focusMinutesToday(in: statistics.weeklyProgress, now: now, calendar: calendar)
    let hasActiveFocus = activeFocus?.status.isActiveLifecycle == true
    let mood = resolveMood(
      statistics: statistics,
      tasks: tasks,
      hasActiveFocus: hasActiveFocus,
      todayFocusMinutes: todayMinutes,
      now: now,
      calendar: calendar
    )
    let copy = greetingCopy(for: mood, statistics: statistics, todayMinutes: todayMinutes)
    let motivation = motivationalMessage(for: mood, statistics: statistics, now: now, calendar: calendar)
    let openTasks = tasks.contains { $0.status != .archived && !$0.isCompleted }

    return DashboardSnapshot(
      mood: mood,
      greetingTitle: copy.title,
      greetingSubtitle: copy.subtitle,
      statistics: statistics,
      priorities: DashboardPriorityEngine.recommendations(from: tasks, now: now, calendar: calendar),
      continuity: continuityState(
        hasActiveFocus: hasActiveFocus,
        hasActiveRest: activeRest,
        activeFocus: activeFocus
      ),
      motivationalTitle: motivation.title,
      motivationalBody: motivation.body,
      todayFocusMinutes: todayMinutes,
      hasOpenTasks: openTasks
    )
  }

  static func activeSessionSnapshot(
    session: FocusSession,
    taskTitle: String?,
    timerEngine: TimerEngine,
    now: Date = .now
  ) -> DashboardActiveSessionSnapshot {
    let remaining = timerEngine.remainingSeconds(at: now)
    return DashboardActiveSessionSnapshot(
      sessionID: session.id,
      title: session.title,
      taskTitle: taskTitle,
      progress: timerEngine.progress(at: now),
      remainingSeconds: remaining,
      remainingLabel: FocusTimerFormatting.remainingLabel(seconds: remaining),
      isPaused: session.status == .paused,
      accessibilitySummary: session.accessibilityStatusLabel
        + ". "
        + (session.accessibilityRemainingDescription(at: now) ?? "")
        + (taskTitle.map { ". Task: \($0)" } ?? "")
    )
  }

  // MARK: - Mood

  static func resolveMood(
    statistics: StatisticsSummary,
    tasks: [Task],
    hasActiveFocus: Bool,
    todayFocusMinutes: Int,
    now: Date,
    calendar: Calendar
  ) -> DashboardMood {
    if hasActiveFocus { return .activeFocus }

    let trackable = tasks.filter { $0.status != .archived }
    let openTasks = trackable.filter { !$0.isCompleted }

    if trackable.isEmpty && statistics.totalCompletedSessions == 0 {
      return .empty
    }

    if openTasks.isEmpty && todayFocusMinutes > 0 {
      return .completedDay
    }

    let sessionsToday = sessionsTodayCount(in: statistics.weeklyProgress, now: now, calendar: calendar)
    if todayFocusMinutes >= 45 || sessionsToday >= 2 {
      return .highProductivity
    }

    let hour = calendar.component(.hour, from: now)
    if hour < 12 && todayFocusMinutes == 0 {
      return .morning
    }

    if hour >= 18 && todayFocusMinutes < 15 {
      return .recovery
    }

    return .recovery
  }

  // MARK: - Private

  private static func focusMinutesToday(
    in weekly: WeeklyProgress,
    now: Date,
    calendar: Calendar
  ) -> Int {
    weekly.dailyFocus
      .first { calendar.isDate($0.date, inSameDayAs: now) }?
      .focusMinutes ?? 0
  }

  private static func sessionsTodayCount(
    in weekly: WeeklyProgress,
    now: Date,
    calendar: Calendar
  ) -> Int {
    weekly.dailyFocus
      .first { calendar.isDate($0.date, inSameDayAs: now) }?
      .sessionCount ?? 0
  }

  private static func greetingCopy(
    for mood: DashboardMood,
    statistics: StatisticsSummary,
    todayMinutes: Int
  ) -> (title: String, subtitle: String) {
    switch mood {
    case .empty:
      return ("Welcome", "Your calm productivity home is ready when you are.")
    case .morning:
      return ("Good morning", "A gentle start can set a steady tone for the day.")
    case .activeFocus:
      return ("Focus in progress", "Pick up where you left off—no rush.")
    case .highProductivity:
      return ("Steady rhythm", "You're building meaningful focus time today.")
    case .recovery:
      return ("Easy pace", "Rest and small steps count. Return when it feels right.")
    case .completedDay:
      return ("Day well spent", "You've made calm progress. Wind down when you're ready.")
    }
  }

  private static func motivationalMessage(
    for mood: DashboardMood,
    statistics: StatisticsSummary,
    now: Date,
    calendar: Calendar
  ) -> MotivationMessage {
    switch mood {
    case .empty:
      return MotivationMessageGenerator.message(for: .dailyEncouragement, seed: now, calendar: calendar)
    case .morning:
      return MotivationMessage(
        title: "Morning intention",
        body: "One small task and a short focus block can be enough."
      )
    case .activeFocus:
      return MotivationMessage(
        title: "Stay with it",
        body: "Your session is here. Pause anytime—you're in control."
      )
    case .highProductivity:
      if statistics.streak.currentStreakDays > 0 {
        return MotivationMessageGenerator.message(
          for: .streak(days: statistics.streak.currentStreakDays),
          seed: now,
          calendar: calendar
        )
      }
      return MotivationMessage(
        title: "Sustainable pace",
        body: statistics.trend.insight
      )
    case .recovery:
      return MotivationMessage(
        title: "Low pressure",
        body: "This week is lighter than last. Rest counts; return when you're ready."
      )
    case .completedDay:
      return MotivationMessageGenerator.message(for: .dailyEncouragement, seed: now, calendar: calendar)
    }
  }

  private static func continuityState(
    hasActiveFocus: Bool,
    hasActiveRest: Bool,
    activeFocus: FocusSession?
  ) -> DashboardContinuityState {
    guard hasActiveFocus || hasActiveRest else {
      return .none
    }

    var hint: String?
    if hasActiveFocus, let session = activeFocus {
      hint = session.status == .paused
        ? "Your focus session is paused and ready to resume."
        : "Your focus session is active across scenes."
    } else if hasActiveRest {
      hint = "A rest break is in progress on the Rest tab."
    }

    return DashboardContinuityState(
      hasActiveFocus: hasActiveFocus,
      hasActiveRest: hasActiveRest,
      canResumeFocus: activeFocus?.status == .paused,
      restorationHint: hint
    )
  }
}
