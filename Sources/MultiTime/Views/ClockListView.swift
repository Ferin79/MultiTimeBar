import SwiftUI

struct ClockListView: View {
    @EnvironmentObject private var clockStore: ClockStore
    @State private var editingClock: Clock?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Your Clocks")
                    .font(.subheadline).bold()
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(clockStore.clocks.count) / ∞")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            List {
                ForEach(clockStore.clocks) { clock in
                    row(clock)
                }
                .onMove { indexSet, dest in
                    clockStore.move(from: indexSet, to: dest)
                }
            }
            .listStyle(.plain)
            .frame(minHeight: 140)
            .sheet(item: $editingClock) { clock in
                EditClockSheet(clock: clock)
                    .environmentObject(clockStore)
            }
        }
    }

    private func row(_ clock: Clock) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.tertiary)
            Text(FlagEmoji.from(countryCode: clock.countryCode))
            VStack(alignment: .leading, spacing: 1) {
                Text(clock.label)
                Text(clock.timezoneIdentifier)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(offsetLabel(for: clock))
                .font(.caption)
                .foregroundStyle(.secondary)
            Button {
                editingClock = clock
            } label: {
                Image(systemName: "pencil")
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.orange)

            Button(role: .destructive) {
                clockStore.remove(clock)
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.red)
        }
        .padding(.vertical, 2)
    }

    private func offsetLabel(for clock: Clock) -> String {
        let localOffset = TimeZone.current.secondsFromGMT()
        let clockOffset = clock.timeZone.secondsFromGMT()
        let hours = Double(clockOffset - localOffset) / 3600.0
        if hours == hours.rounded() {
            let intHours = Int(hours)
            return intHours >= 0 ? "(+\(intHours)h)" : "(\(intHours)h)"
        } else {
            let sign = hours >= 0 ? "+" : ""
            return "(\(sign)\(String(format: "%.1f", hours))h)"
        }
    }
}

private struct EditClockSheet: View {
    @EnvironmentObject private var clockStore: ClockStore
    @Environment(\.dismiss) private var dismiss
    @State var clock: Clock

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Edit Clock")
                .font(.headline)
            LabeledContent("Label") {
                TextField("Label", text: $clock.label)
                    .textFieldStyle(.roundedBorder)
            }
            LabeledContent("Time zone") {
                Text(clock.timezoneIdentifier)
                    .foregroundStyle(.secondary)
            }
            LabeledContent("Country code") {
                TextField("Country code", text: $clock.countryCode)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
            }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") {
                    clockStore.update(clock)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 360)
    }
}
