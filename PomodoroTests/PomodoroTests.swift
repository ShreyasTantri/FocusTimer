//
//  PomodoroTests.swift
//  PomodoroTests
//
//  Created by Sree Sai Raghava Dandu on 14/09/26.
//

import Testing
import Foundation
@testable import Pomodoro

struct PomodoroTests {

    @Test
    func idleTimerShowsFullSelectedSessionDuration() {
        let viewModel = PomodoroViewModel()
        
        #expect(viewModel.remainingTime(at: Date(timeIntervalSince1970: 0)) == 25 * 60)
    }
    
    @Test
    func remainingTimeImmediatelyAfterStart() {
        let viewModel = PomodoroViewModel()
        let startDate = Date(timeIntervalSince1970: 0)
        let tenMinLater = startDate.addingTimeInterval(10 * 60)
        viewModel.timer.sessionType = .work
        viewModel.start(at: startDate)
        
        #expect(viewModel.remainingTime(at: tenMinLater) == 15 * 60)
    }

}
