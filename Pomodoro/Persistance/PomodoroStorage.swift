//
//  PomodoroStorage.swift
//  Pomodoro
//
//  Created by Sree Sai Raghava Dandu on 19/09/26.
//

import Foundation

protocol PomodoroStorage {
    func loadSettings() -> PomodoroSettings
    func saveSettings(_ settings: PomodoroSettings)
    
    func loadStats() -> PomodoroStats
    func saveStats(_ stats: PomodoroStats)
}

final class UserDefaultsPomodoroStorage: PomodoroStorage {
    static let shared = UserDefaultsPomodoroStorage()
    
    private enum Key {
        static let settings = "pomodoro.settings"
        static let stats = "pomodoro.stats"
    }
    
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(defualts: UserDefaults = .standard) {
        self.defaults = defualts
    }
    
    func loadSettings() -> PomodoroSettings {
        load(PomodoroSettings.self, forKey: Key.settings) ?? PomodoroSettings()
    }
    
    func saveSettings(_ settings: PomodoroSettings) {
        save(settings, forKey: Key.settings)
    }
    
    func loadStats() -> PomodoroStats {
        load(PomodoroStats.self, forKey: Key.stats) ?? PomodoroStats()
    }
    
    func saveStats(_ stats: PomodoroStats) {
        save(stats, forKey: Key.stats)
    }
    
    private func load<Value: Decodable>(_ type: Value.Type, forKey key: String) -> Value? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        return try? decoder.decode(type, from: data)
    }
    
    private func save<Value: Encodable>(_ value: Value, forKey key: String) {
        guard let data = try? encoder.encode(value) else {
            return
        }
        defaults.set(data, forKey: key)
    }
}
