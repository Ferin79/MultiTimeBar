import SwiftUI
import AppKit

/// The popover shown when the user clicks the menu bar icon.
struct MenuBarContentView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var clockStore: ClockStore
    @EnvironmentObject private var timeTravel: TimeTravelState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            clockList
            Divider()
            footer
        }
        .frame(width: 300)
    }

    private var header: some View {
        HStack {
            Text("MultiTimeBar")
                .font(.headline)
            Spacer()
            if timeTravel.isActive {
                Label("Time Travel", systemImage: "clock.arrow.circlepath")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var clockList: some View {
        TimelineView(.periodic(from: .now, by: settings.showSeconds ? 1 : 30)) { context in
            let now = context.date.addingTimeInterval(timeTravel.isActive ? timeTravel.offset : 0)
            VStack(spacing: 0) {
                ForEach(clockStore.clocks) { clock in
                    row(for: clock, at: now)
                }
                if clockStore.clocks.isEmpty {
                    Text("No clocks added yet.")
                        .foregroundStyle(.secondary)
                        .padding(12)
                }
            }
        }
    }

    private func row(for clock: Clock, at now: Date) -> some View {
        HStack(spacing: 8) {
            Text(FlagEmoji.from(countryCode: clock.countryCode))
                .font(.title3)
            VStack(alignment: .leading, spacing: 1) {
                Text(clock.label)
                    .font(.system(.body, design: .default))
                Text(TimeFormatting.dateString(for: clock, at: now))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                Text(TimeFormatting.timeString(
                    for: clock,
                    at: now,
                    use24Hour: settings.use24Hour,
                    showSeconds: settings.showSeconds
                ))
                .font(.system(.body, design: .monospaced))
                if let suffix = TimeFormatting.dayDifferenceSuffix(
                    TimeFormatting.dayDifference(for: clock, at: now)
                ) {
                    Text(suffix)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var footer: some View {
        VStack(spacing: 2) {
            if settings.showTimeTravel {
                footerButton(title: "Time Travel Planner…", systemImage: "clock.arrow.2.circlepath") {
                    NSLog("MultiTimeBar: TimeTravel button pressed")
                    AppDelegate.shared?.openTimeTravel()
                }
            }
            footerButton(title: "Settings…", systemImage: "gearshape") {
                NSLog("MultiTimeBar: Settings button pressed")
                AppDelegate.shared?.openSettings()
            }
            footerButton(title: "Quit MultiTimeBar", systemImage: "power") {
                NSApp.terminate(nil)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
    }

    private func footerButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .frame(width: 18)
                Text(title)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
    }
}
