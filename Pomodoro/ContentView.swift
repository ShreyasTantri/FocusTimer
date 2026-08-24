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
  ├── VStack
  │    ├── countdown text
  │    └── Start button
 
 */

struct ContentView: View {
    @State private var viewModel = PomodoroViewModel()
    var body: some View {
        VStack {
            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                if viewModel.remainingTime <= 0 {
//                    viewModel.completeSession()
                }
                
                Text(timeString(from: viewModel.remainingTime))
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
            }
            
            Button("Start") {
                viewModel.start()
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
}


#Preview {
    ContentView()
}
