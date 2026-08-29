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
    var timeLeftOnPause: TimeInterval?
}

enum TimerState {
    case idle
    case running
    case paused
    case completed
}

enum SessionType: String, CaseIterable {
    case work = "Work"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
    
    var durationInSeconds: TimeInterval {
        switch self {
        case .work:
            return 25 * 60
        case .shortBreak:
            return 5 * 60
        case .longBreak:
            return 15 * 60
        }
    }
}
