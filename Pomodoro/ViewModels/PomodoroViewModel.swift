import Foundation

@Observable
final class PomodoroViewModel {
    var timer = PomodoroTimer(state: .idle, sessionType: .shortBreak, endTime: nil, timeLeftOnPause: nil)
    var completedWorkSessions: Int = 0
    
    func start() {
        timer.endTime = Date().addingTimeInterval(timer.sessionType.durationInSeconds)
        timer.state = .running
    }
    
    var remainingTime: TimeInterval {
        if let timeLeftOnPause = timer.timeLeftOnPause {
            return timeLeftOnPause
        }
        
        if let endTime = timer.endTime {
            return max(0, endTime.timeIntervalSinceNow)
        }
        return 0
    }
    
    var progress: Double {
        let total = timer.sessionType.durationInSeconds
        guard total > 0 else { return 0 }
        return remainingTime / total
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
    
    func pause() {
        timer.state = .paused
        timer.timeLeftOnPause = remainingTime
        timer.endTime = nil
    }
    
    func resume() {
        guard let timeToAdd = timer.timeLeftOnPause else {
            return
        }
        
        timer.endTime = Date().addingTimeInterval(timeToAdd)
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
    
}
