//
//  ContentView.swift
//  Pomodoro
//
//  Created by CCS038 on 09/08/26.
//
import SwiftUI

struct ContentView: View {
    @State private var viewModel = PomodoroViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        VStack {
            Text("Completed sessions: \(viewModel.completedWorkSessions)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Picker("Session Type", selection: $viewModel.timer.sessionType) {
                ForEach(SessionType.allCases, id: \.self) { session in
                    Text(session.rawValue).tag(session)
                }
            }
            .disabled(viewModel.timer.state == .paused || viewModel.timer.state == .running)
            .pickerStyle(.segmented)
            
            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                ProgressRingView(
                    progress: viewModel.progress,
                    timeString: timeString(from: viewModel.remainingTime)
                )
                .task(id: context.date) {
                    viewModel.updateTimer(at: context.date)
                }
            }
            ControlButtonsView(viewModel: viewModel)
        }
        .padding()
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                viewModel.updateTimer(at: .now)
            }
        }
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
            viewModel.reset()
        }
    }
}

struct ProgressRingView: View {
    let progress: Double
    let timeString: String
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 15)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear(duration: 1.0), value: progress)
            
            Text(timeString)
                .font(.system(size: 60, weight: .bold, design: .monospaced))
        }
        .padding(40)
    }
}

struct ControlButtonModifier: ViewModifier {
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .font(.title)
            .foregroundColor(.white)
            .frame(width: 70, height: 70)
            .background(color.gradient)
            .clipShape(Circle())
            .shadow(radius: 3, y: 3)
    }
}

struct ControlButtonsView: View {
    let viewModel: PomodoroViewModel
    
    var body: some View {
        HStack(spacing: 30) {
            switch viewModel.timer.state {
            case .idle, .completed:
                Button(action: { viewModel.start() }) {
                    Image(systemName: "play.fill")
                        .modifier(ControlButtonModifier(color: .blue))
                }
                
            case .running:
                Button(action: { viewModel.pause() }) {
                    Image(systemName: "pause.fill")
                        .modifier(ControlButtonModifier(color: .orange))
                }
                Button(action: { viewModel.reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .modifier(ControlButtonModifier(color: .red))
                }
                
            case .paused:
                Button(action: { viewModel.resume() }) {
                    Image(systemName: "play.fill")
                        .modifier(ControlButtonModifier(color: .green))
                }
                Button(action: { viewModel.reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .modifier(ControlButtonModifier(color: .red))
                }
            }
        }
        .padding(.top, 20)
    }
}

#Preview {
    ContentView()
}
