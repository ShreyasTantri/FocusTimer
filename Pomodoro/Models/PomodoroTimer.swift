//
//  PomodoroTimer.swift
//  Pomodoro
//
//  Created by CCS038 on 23/08/26.
//

import Foundation

struct PomodoroTimer {
    var state: TimerState
    var sessionType: SessionType
    var endTime: Date?
}

enum TimerState {
    case idle
    case running
    case paused
    case completed
}

enum SessionType {
    case work
    case shortBreak
    case longBreak
}
