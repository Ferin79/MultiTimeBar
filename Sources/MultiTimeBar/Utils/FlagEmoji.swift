import Foundation

enum FlagEmoji {
    /// Converts an ISO 3166-1 alpha-2 country code to its regional-indicator flag emoji.
    static func from(countryCode: String) -> String {
        let code = countryCode.uppercased()
        guard code.count == 2 else { return "🏳️" }
        let base: UInt32 = 127397 // 🇦 - 'A'
        var scalars = String.UnicodeScalarView()
        for char in code.unicodeScalars {
            guard let scalar = UnicodeScalar(base + char.value) else { return "🏳️" }
            scalars.append(scalar)
        }
        return String(scalars)
    }
}
