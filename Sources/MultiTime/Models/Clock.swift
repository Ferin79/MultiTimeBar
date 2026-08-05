import Foundation

struct Clock: Identifiable, Codable, Hashable {
    var id: UUID
    var label: String            // Display name (e.g. "Seoul")
    var timezoneIdentifier: String   // IANA identifier (e.g. "Asia/Seoul")
    var countryCode: String      // ISO 3166-1 alpha-2 (e.g. "KR")

    init(id: UUID = UUID(), label: String, timezoneIdentifier: String, countryCode: String) {
        self.id = id
        self.label = label
        self.timezoneIdentifier = timezoneIdentifier
        self.countryCode = countryCode
    }

    var timeZone: TimeZone {
        TimeZone(identifier: timezoneIdentifier) ?? .current
    }
}
