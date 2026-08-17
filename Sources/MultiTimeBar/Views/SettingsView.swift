import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var clockStore: ClockStore

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 10)
            Divider()
            HStack(alignment: .top, spacing: 0) {
                leftColumn
                    .frame(width: 240)
                    .padding(20)
                Divider()
                rightColumn
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(20)
            }
            .frame(maxHeight: .infinity)
            Divider()
            footer
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
        }
        .frame(minWidth: 640, minHeight: 460)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "clock.badge")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 1) {
                Text("MultiTimeBar")
                    .font(.headline)
                Text("Version \(Bundle.main.appVersion)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var footer: some View {
        VStack(spacing: 2) {
            Text("Open source. Contributions welcome!")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("github.com/Ferin79/MultiTimeBar")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var leftColumn: some View {
        VStack(alignment: .leading, spacing: 18) {
            section("Display") {
                Toggle("Use 24-hour format", isOn: $settings.use24Hour)
                Toggle("Show seconds", isOn: $settings.showSeconds)
                Toggle("Show flags", isOn: $settings.showFlags)
                Toggle("Show day difference", isOn: $settings.showDayDifference)
            }
            section("Layout") {
                Toggle("Stack clocks in two rows", isOn: $settings.stackInTwoRows)
                Toggle("Show Time Travel planner", isOn: $settings.showTimeTravel)
            }
            section("General") {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
            }
            Spacer(minLength: 0)
        }
    }

    private var rightColumn: some View {
        VStack(alignment: .leading, spacing: 16) {
            AddClockView()
            Divider()
            ClockListView()
        }
    }

    @ViewBuilder
    private func section<Content: View>(
        _ title: String,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline).bold()
                .foregroundStyle(.secondary)
            content()
                .toggleStyle(.checkbox)
        }
    }
}

private extension Bundle {
    var appVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0"
    }
}
