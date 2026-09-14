//
//  SettingsView.swift
//  Pomodoro
//
//  Created by Sree Sai Raghava Dandu on 14/09/26.
//

import SwiftUI

struct SettingsView: View {
    let viewModel: PomodoroViewModel
    var body: some View {
        NavigationStack {
            Form {
                Section("Durations") {
                    DurationStepper(title: "Work", minutes: viewModel.settings.workDuration / 60, range: 1...120) { minutes in viewModel.updateWorkDuration(minutes: minutes) }
                    DurationStepper(title: "Short Break", minutes: viewModel.settings.shortBreakDuration / 60, range: 1...60) { minutes in viewModel.updateShortBreakDuration(minutes: minutes) }
                    DurationStepper(title: "Long Break", minutes: viewModel.settings.longBreakDuration / 60, range: 1...90) { minutes in viewModel.updateLongBreakDuration(minutes: minutes) }
                }
            }
        }
        .navigationTitle("Timer Settings")
    }
}

#Preview {
    SettingsView(viewModel: PomodoroViewModel())
}
