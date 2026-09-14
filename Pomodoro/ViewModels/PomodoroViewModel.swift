import Foundation

@Observable
final class PomodoroViewModel {
    var timer = PomodoroTimer(state: .idle, sessionType: .work, endTime: nil, timeLeftOnPause: nil)
    var completedWorkSessions: Int = 0
    
    var settings = PomodoroSettings()
    
    var statusText: String {
        switch timer.state {
        case .idle:
            return "Ready to Start"
        case .running:
            return "Stay Focused"
        case .paused:
            return "Paused"
        case .completed:
            return "Nice Work!"
        }
    }
    
    func start(at date: Date = .now) {
        timer.endTime = date.addingTimeInterval(duration(for: timer.sessionType))
        timer.state = .running
    }
    
    func remainingTime(at date: Date = .now) -> TimeInterval {
        if let timeLeftOnPause = timer.timeLeftOnPause {
            return timeLeftOnPause
        }
        
        if let endTime = timer.endTime {
            return max(0, endTime.timeIntervalSince(date))
        }
        return duration(for: timer.sessionType)
    }
    
    func progress(at date: Date = .now) -> Double {
        let total = duration(for: timer.sessionType)
        guard total > 0 else { return 0 }
        return remainingTime(at: date) / total
    }
    
    func updateTimer(at date: Date) {
        guard timer.state == .running else {
            return
        }

        guard let endTime = timer.endTime else {
            return
        }

        if date >= endTime {
            completeSession()
        }
    }
    
    func pause(at date: Date = .now) {
        updateTimer(at: date)
        guard timer.state == .running else {
            return
        }
        
        timer.state = .paused
        timer.timeLeftOnPause = remainingTime(at: date)
        timer.endTime = nil
    }
    
    func resume(at date: Date = .now) {
        guard let timeToAdd = timer.timeLeftOnPause else {
            return
        }
        
        timer.endTime = date.addingTimeInterval(timeToAdd)
        timer.state = .running
        timer.timeLeftOnPause = nil
    }
    
    func reset() {
        timer.state = .idle
        timer.endTime = nil
        timer.timeLeftOnPause = nil
    }
    
    func completeSession() {
        timer.state = .completed
        
        if timer.sessionType == .work {
            completedWorkSessions += 1
        }
    }
    
    func duration(for sessionType: SessionType) -> TimeInterval {
        switch sessionType {
        case .work:
            return settings.workDuration
        case .shortBreak:
            return settings.shortBreakDuration
        case .longBreak:
            return settings.longBreakDuration
        }
    }
    
    func updateWorkDuration(minutes: Double) {
        settings.workDuration = minutes * 60
        reset()
    }
    
    func updateShortBreakDuration(minutes: Double) {
        settings.shortBreakDuration = minutes * 60
        reset()
    }
    
    func updateLongBreakDuration(minutes: Double) {
        settings.longBreakDuration = minutes * 60
        reset()
    }
}
