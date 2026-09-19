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
    @State private var isShowingSettings = false
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                ScrollView {
                    timerContent
                }
                .scrollIndicators(.hidden)
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView(viewModel: viewModel)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                viewModel.updateTimer(at: .now)
            }
        }
    }
    
    // Timer Content
    private var timerContent: some View {
        VStack(spacing: 24) {
            sessionHeader
            
            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                ProgressRingView(
                    progress: viewModel.progress(at: context.date),
                    timeString: timeString(from: viewModel.remainingTime(at: context.date)),
                    color: sessionColor
                )
                .task(id: context.date) {
                    viewModel.updateTimer(at: context.date)
                }
            }
            
            // Completion Card
            if viewModel.timer.state == .completed {
                completionCard
            }
            
            sessionPicker
            
            ControlButtonsView(viewModel: viewModel, primaryColor: sessionColor)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 40)
    }
    
    private var sessionPicker: some View {
        Picker("Session Type", selection: $viewModel.timer.sessionType) {
            ForEach(SessionType.allCases, id: \.self) { session in
                Text(session.rawValue).tag(session)
            }
        }
        .disabled(viewModel.timer.state == .paused || viewModel.timer.state == .running)
        .pickerStyle(.segmented)
    }
    // TopBar
    private var topBar: some View {
        HStack {
            Text("Pomodoro")
                .font(.title2.weight(.bold))
            
            Spacer()
            
            Button {
                isShowingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .font(.system(size:16, weight: .semibold))
                    .frame(width: 40, height: 40)
                    .background(.thinMaterial)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding([.top, .bottom], 12)
        .background(.thinMaterial)
    }
    
    // Session Header
    private var sessionHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: sessionIconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(sessionColor)
            Text(viewModel.timer.sessionType.rawValue)
                .font(.title.weight(.semibold))
            Text(viewModel.statusText)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Label("\(viewModel.completedWorkSessions) completed", systemImage: "checkmark.circle.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.thinMaterial)
                .clipShape(Capsule())
        }
    }
    // Session Color
    private var sessionColor: Color {
        switch viewModel.timer.sessionType {
        case .work:
            return .blue
        case .shortBreak:
            return .green
        case .longBreak:
            return .purple
        }
    }
    // CompletionCard
    private var completionCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(sessionColor)
            Text(viewModel.completionTitle)
                .font(.headline.weight(.semibold))
            Text(viewModel.completionMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 12)
    }
    private var backgroundGradient: LinearGradient {
        LinearGradient(colors: [sessionColor.opacity(0.18), Color(.systemBackground)], startPoint: .top, endPoint: .bottom)
    }
    
    private var sessionIconName: String {
        switch viewModel.timer.sessionType {
        case .work:
            return "brain.head.profile"
        case .shortBreak:
            return "cup.and.saucer.fill"
        case .longBreak:
            return "leaf.fill"
        }
    }
    private func timeString(from time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ProgressRingView: View {
    let progress: Double
    let timeString: String
    let color: Color
    private let ringSize: CGFloat = 260
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.16), lineWidth: 18)
                .opacity(0.3)
                .foregroundColor(.gray)
                .frame(width: ringSize, height: ringSize)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(color.gradient, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .shadow(color: color.opacity(0.35), radius: 12)
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear(duration: 1.0), value: progress)
                .frame(width: ringSize, height: ringSize)
            
            VStack(spacing: 8) {
                Text(timeString)
                    .font(.system(size: 58, weight: .bold, design: .rounded))
                Text("remaining")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
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
    let primaryColor: Color
    
    var body: some View {
        HStack(spacing: 30) {
            switch viewModel.timer.state {
            case .idle:
                controlButton(icon: "play.fill", title: "Start", color: primaryColor) {
                    viewModel.start()
                }
                
            case .completed:
                controlButton(icon: "arrow.clockwise", title: "Start Again", color: primaryColor) {
                    viewModel.start()
                }
                
            case .running:
                controlButton(icon: "pause.fill", title: "Pause", color: primaryColor) {
                    viewModel.pause()
                }
                
                controlButton(icon: "arrow.counterclockwise", title: "Reset", color: .red) {
                    viewModel.reset()
                }
                
            case .paused:
                controlButton(icon: "play.fill", title: "Resume", color: primaryColor) {
                    viewModel.resume()
                }
                controlButton(icon: "arrow.counterclockwise", title: "Reset", color: .red) {
                    viewModel.reset()
                }
            }
        }
        .padding(.top, 20)
    }
    
    private func controlButton(
        icon: String,
        title: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 8) {
            Button(action: action) {
                Image(systemName: icon)
                    .modifier(ControlButtonModifier(color: color))
            }
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
