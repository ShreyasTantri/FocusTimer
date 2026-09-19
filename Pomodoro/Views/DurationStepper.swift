//
//  DurationStepper.swift
//  Pomodoro
//
//  Created by Sree Sai Raghava Dandu on 14/09/26.
//

import SwiftUI

struct DurationStepper: View {
    let title: String
    let minutes: Double
    let range: ClosedRange<Double>
    let onChange: (Double) -> Void
    var body: some View {
        Stepper(value: Binding(
            get: { minutes },
            set: { onChange($0)}
        ), in: range, step: 1) {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(minutes)) min")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.thinMaterial)
                    .clipShape(Capsule())
            }
        }
    }
}
