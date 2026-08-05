import SwiftUI

struct TimeTravelView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var clockStore: ClockStore
    @EnvironmentObject private var timeTravel: TimeTravelState

    /// Slider bounds in hours (relative to now).
    private let range: ClosedRange<Double> = -48...48

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Toggle("Enable Time Travel", isOn: $timeTravel.isActive)
                    .toggleStyle(.switch)
                Spacer()
                Button("Reset to Now") {
                    timeTravel.reset()
                }
                .disabled(timeTravel.offset == 0 && !timeTravel.isActive)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Offset: \(offsetLabel)")
                        .font(.headline)
                    Spacer()
                }
                Slider(
                    value: Binding(
                        get: { timeTravel.offset / 3600.0 },
                        set: { timeTravel.offset = $0 * 3600.0 }
                    ),
                    in: range,
                    step: 0.25
                ) {
                    Text("Offset")
                } minimumValueLabel: {
                    Text("-48h").font(.caption).foregroundStyle(.secondary)
                } maximumValueLabel: {
                    Text("+48h").font(.caption).foregroundStyle(.secondary)
                }
                .disabled(!timeTravel.isActive)
            }

            Divider()

            Text("Preview")
                .font(.subheadline).bold()
                .foregroundStyle(.secondary)

            TimelineView(.periodic(from: .now, by: 1)) { context in
                let now = context.date.addingTimeInterval(timeTravel.offset)
                VStack(spacing: 0) {
                    ForEach(clockStore.clocks) { clock in
                        previewRow(clock, at: now)
                    }
                }
            }

            Spacer()

            Text("Turn on Time Travel and drag the slider to see when a meeting time falls across your clocks. Real time is not affected.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(minWidth: 460, minHeight: 460)
    }

    private var offsetLabel: String {
        let hours = timeTravel.offset / 3600.0
        if hours == 0 { return "Now" }
        let sign = hours > 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", hours))h"
    }

    private func previewRow(_ clock: Clock, at now: Date) -> some View {
        HStack(spacing: 8) {
            Text(FlagEmoji.from(countryCode: clock.countryCode))
            VStack(alignment: .leading, spacing: 1) {
                Text(clock.label)
                Text(TimeFormatting.dateString(for: clock, at: now))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(TimeFormatting.timeString(
                for: clock,
                at: now,
                use24Hour: settings.use24Hour,
                showSeconds: settings.showSeconds
            ))
            .font(.system(.body, design: .monospaced))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
    }
}
