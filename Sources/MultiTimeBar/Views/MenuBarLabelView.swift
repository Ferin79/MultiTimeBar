import SwiftUI

/// The multi-clock display shown in the menu bar itself.
struct MenuBarLabelView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var clockStore: ClockStore
    @EnvironmentObject private var timeTravel: TimeTravelState

    var body: some View {
        // TimelineView drives per-second updates without a manual Timer.
        TimelineView(.periodic(from: .now, by: settings.showSeconds ? 1 : 30)) { context in
            let now = context.date.addingTimeInterval(timeTravel.isActive ? timeTravel.offset : 0)
            content(at: now)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: true)
        }
    }

    @ViewBuilder
    private func content(at now: Date) -> some View {
        let clocks = clockStore.clocks
        if clocks.isEmpty {
            // Fallback icon so the menu bar item is always visible.
            Image(systemName: "clock.badge")
                .foregroundColor(Color(nsColor: .labelColor))
        } else if settings.stackInTwoRows && clocks.count > 1 {
            let mid = (clocks.count + 1) / 2
            let firstRow = Array(clocks.prefix(mid))
            let secondRow = Array(clocks.dropFirst(mid))
            VStack(alignment: .leading, spacing: 0) {
                row(firstRow, at: now)
                row(secondRow, at: now)
            }
        } else {
            row(clocks, at: now)
        }
    }

    private func row(_ clocks: [Clock], at now: Date) -> some View {
        HStack(spacing: 8) {
            ForEach(clocks) { clock in
                clockLabel(clock, at: now)
            }
        }
    }

    private func clockLabel(_ clock: Clock, at now: Date) -> some View {
        HStack(spacing: 3) {
            if settings.showFlags {
                Text(FlagEmoji.from(countryCode: clock.countryCode))
            }
            Text(TimeFormatting.timeString(
                for: clock,
                at: now,
                use24Hour: settings.use24Hour,
                showSeconds: settings.showSeconds
            ))
            // Explicit label color — SwiftUI's implicit `Color.primary` can
            // render as clear inside an NSStatusItem hosting view on some
            // macOS versions, making the time text invisible.
            .foregroundColor(Color(nsColor: .labelColor))
            if settings.showDayDifference,
               let suffix = TimeFormatting.dayDifferenceSuffix(
                    TimeFormatting.dayDifference(for: clock, at: now)
               ) {
                Text(suffix)
                    .foregroundColor(Color(nsColor: .labelColor).opacity(0.65))
            }
        }
    }
}
