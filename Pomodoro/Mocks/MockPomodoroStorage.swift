//
//  MockPomodoroStorage.swift
//  Pomodoro
//
//  Created by Sree Sai Raghava Dandu on 19/09/26.
//

import Foundation

final class MockPomodoroStorage: PomodoroStorage {
    func loadSettings() -> PomodoroSettings {
        return PomodoroSettings()
    }
    
    func saveSettings(_ settings: PomodoroSettings) {
        print("Settings Saved as \(settings)")
    }
    
    func loadStats() -> PomodoroStats {
        return PomodoroStats()
    }
    
    func saveStats(_ stats: PomodoroStats) {
        print("Stats Saved as \(stats)")
    }
    
    
}
