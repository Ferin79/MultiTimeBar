import Foundation

enum TimeFormatting {
    /// Returns the time-of-day string for the given clock, honoring 24h/seconds settings.
    static func timeString(for clock: Clock, at date: Date, use24Hour: Bool, showSeconds: Bool) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = clock.timeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if use24Hour {
            formatter.dateFormat = showSeconds ? "HH:mm:ss" : "HH:mm"
        } else {
            formatter.dateFormat = showSeconds ? "h:mm:ss a" : "h:mm a"
        }
        return formatter.string(from: date)
    }

    /// Returns a full date string like "Fri Jun 12" in the clock's time zone.
    static func dateString(for clock: Clock, at date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = clock.timeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE MMM d"
        return formatter.string(from: date)
    }

    /// Difference in calendar days between the clock's time zone and the user's local time zone.
    /// Positive when the clock is ahead (e.g. +1d), negative when behind.
    static func dayDifference(for clock: Clock, at date: Date) -> Int {
        var localCal = Calendar(identifier: .gregorian)
        localCal.timeZone = TimeZone.current
        var clockCal = Calendar(identifier: .gregorian)
        clockCal.timeZone = clock.timeZone

        let localDay = localCal.dateComponents([.year, .month, .day], from: date)
        let clockDay = clockCal.dateComponents([.year, .month, .day], from: date)

        guard let localDate = localCal.date(from: localDay),
              let clockDate = localCal.date(from: clockDay) else { return 0 }
        let comps = localCal.dateComponents([.day], from: localDate, to: clockDate)
        return comps.day ?? 0
    }

    static func dayDifferenceSuffix(_ diff: Int) -> String? {
        guard diff != 0 else { return nil }
        return diff > 0 ? "(+\(diff)d)" : "(\(diff)d)"
    }
}
