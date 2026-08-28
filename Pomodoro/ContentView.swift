//
//  ContentView.swift
//  Pomodoro
//
//  Created by CCS038 on 09/08/26.
//
import SwiftUI

/*
 
 ContentView
  ├── @State ViewModel
  ├── VStackgit branch -M main
  │    ├── countdown text
  │    └── Start button
 
 */

struct ContentView: View {
    @State private var viewModel = PomodoroViewModel()
    var body: some View {
        VStack {
            Picker("Session Type", selection: $viewModel.timer.sessionType) {
                ForEach(SessionType.allCases, id: \.self) { session in
                    Text(session.rawValue).tag(session)
                }
            }
            .disabled(viewModel.timer.state == .paused || viewModel.timer.state == .running)
            .pickerStyle(.segmented)
            
            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                Text(timeString(from: viewModel.remainingTime)).font(.system(size: 60, weight: .bold, design: .monospaced))
                    .task(id: context.date) {
                        viewModel.updateTimer(at: context.date)
                    }
            }
            
            switch viewModel.timer.state {
            case .idle:
                Button("Start") {
                    viewModel.start()
                }
            case .running:
                HStack {
                    Button("Pause") {
                        viewModel.pause()
                    }
                    resetButton()
                }
            case .paused:
                HStack {
                    Button("Resume") {
                        viewModel.resume()
                    }
                    resetButton()
                }
            case .completed:
                Button("Start") {
                    viewModel.start()
                }
            }
        }
        .padding()
    }
    
    private func timeString(from time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @ViewBuilder
    func resetButton() -> some View {
        Button("Reset") {
            viewModel.resume()
        }
    }
}


#Preview {
    ContentView()
}
