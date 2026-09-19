import Foundation

@Observable
final class PomodoroViewModel {
    @ObservationIgnored private let storage: PomodoroStorage
    var timer = PomodoroTimer(state: .idle, sessionType: .work, endTime: nil, timeLeftOnPause: nil)
    var completedWorkSessions: Int = 0 {
        didSet {
            storage.saveStats(
                PomodoroStats(completeWorkSessions: completedWorkSessions)
            )
        }
    }
    
    var settings = PomodoroSettings() {
        didSet {
            storage.saveSettings(settings)
        }
    }
    
    init(storage: PomodoroStorage = UserDefaultsPomodoroStorage.shared) {
        self.storage = storage
        self.settings = storage.loadSettings()
        self.completedWorkSessions = storage.loadStats().completeWorkSessions
    }
    
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
    
    var completionTitle: String {
        switch timer.sessionType {
        case .work: 
            return "Focus session complete"
        case .shortBreak: 
            return "Short break complete"
        case .longBreak: 
            return "Long break complete"
        }
    }
    
    var completionMessage: String {
        switch timer.sessionType {
        case .work: 
            return "Great job staying focused!"
        case .shortBreak: 
            return "Take a break and relax!"
        case .longBreak: 
            return "Enjoy your well-deserved break!"
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
