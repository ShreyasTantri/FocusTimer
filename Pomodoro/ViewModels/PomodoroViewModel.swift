import Foundation

@Observable
final class PomodoroViewModel {
    var timer = PomodoroTimer(state: .idle, sessionType: .shortBreak, endTime: nil, timeLeftOnPause: nil)
    
//    private var ticker: Timer?
//    private var tick = 0
    
    func start() {
        var duration: TimeInterval
        
        switch timer.sessionType {
        case .work:
            duration = 25 * 60
        case .shortBreak:
            duration = 5 * 60
        case .longBreak:
            duration = 15 * 60
        }
        
        timer.endTime = Date().addingTimeInterval(duration)
        timer.state = .running
//        startTicker()
    }
    
//    private func startTicker() {
//        ticker?.invalidate()
//
//        ticker = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
//            guard let self else { return }
//            
//            tick += 1
//            
//            if self.remainingTime <= 0 {
//                self.ticker?.invalidate()
//                self.ticker = nil
//                self.timer.state = .completed
//            }
//        }
//    }
    
    var remainingTime: TimeInterval {
        if let timeLeftOnPause = timer.timeLeftOnPause {
            return timeLeftOnPause
        }
        
        if let endTime = timer.endTime {
            return max(0, endTime.timeIntervalSinceNow)
        }
        return 0
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
    }
    
}

