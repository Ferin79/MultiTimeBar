import Foundation

struct CityEntry: Identifiable, Hashable {
    var id: String { "\(name)|\(timezoneIdentifier)" }
    let name: String
    let country: String
    let countryCode: String
    let timezoneIdentifier: String
}

/// Curated list of major world cities mapped to IANA time zones and ISO country codes.
enum TimezoneDatabase {
    static let cities: [CityEntry] = [
        // Africa
        .init(name: "Cairo", country: "Egypt", countryCode: "EG", timezoneIdentifier: "Africa/Cairo"),
        .init(name: "Casablanca", country: "Morocco", countryCode: "MA", timezoneIdentifier: "Africa/Casablanca"),
        .init(name: "Johannesburg", country: "South Africa", countryCode: "ZA", timezoneIdentifier: "Africa/Johannesburg"),
        .init(name: "Lagos", country: "Nigeria", countryCode: "NG", timezoneIdentifier: "Africa/Lagos"),
        .init(name: "Nairobi", country: "Kenya", countryCode: "KE", timezoneIdentifier: "Africa/Nairobi"),
        .init(name: "Algiers", country: "Algeria", countryCode: "DZ", timezoneIdentifier: "Africa/Algiers"),
        .init(name: "Addis Ababa", country: "Ethiopia", countryCode: "ET", timezoneIdentifier: "Africa/Addis_Ababa"),
        .init(name: "Accra", country: "Ghana", countryCode: "GH", timezoneIdentifier: "Africa/Accra"),
        .init(name: "Tunis", country: "Tunisia", countryCode: "TN", timezoneIdentifier: "Africa/Tunis"),
        .init(name: "Dakar", country: "Senegal", countryCode: "SN", timezoneIdentifier: "Africa/Dakar"),

        // Americas
        .init(name: "New York", country: "United States", countryCode: "US", timezoneIdentifier: "America/New_York"),
        .init(name: "Los Angeles", country: "United States", countryCode: "US", timezoneIdentifier: "America/Los_Angeles"),
        .init(name: "Chicago", country: "United States", countryCode: "US", timezoneIdentifier: "America/Chicago"),
        .init(name: "Denver", country: "United States", countryCode: "US", timezoneIdentifier: "America/Denver"),
        .init(name: "Phoenix", country: "United States", countryCode: "US", timezoneIdentifier: "America/Phoenix"),
        .init(name: "San Francisco", country: "United States", countryCode: "US", timezoneIdentifier: "America/Los_Angeles"),
        .init(name: "Seattle", country: "United States", countryCode: "US", timezoneIdentifier: "America/Los_Angeles"),
        .init(name: "Boston", country: "United States", countryCode: "US", timezoneIdentifier: "America/New_York"),
        .init(name: "Washington", country: "United States", countryCode: "US", timezoneIdentifier: "America/New_York"),
        .init(name: "Miami", country: "United States", countryCode: "US", timezoneIdentifier: "America/New_York"),
        .init(name: "Atlanta", country: "United States", countryCode: "US", timezoneIdentifier: "America/New_York"),
        .init(name: "Dallas", country: "United States", countryCode: "US", timezoneIdentifier: "America/Chicago"),
        .init(name: "Houston", country: "United States", countryCode: "US", timezoneIdentifier: "America/Chicago"),
        .init(name: "Honolulu", country: "United States", countryCode: "US", timezoneIdentifier: "Pacific/Honolulu"),
        .init(name: "Anchorage", country: "United States", countryCode: "US", timezoneIdentifier: "America/Anchorage"),

        .init(name: "Toronto", country: "Canada", countryCode: "CA", timezoneIdentifier: "America/Toronto"),
        .init(name: "Vancouver", country: "Canada", countryCode: "CA", timezoneIdentifier: "America/Vancouver"),
        .init(name: "Montreal", country: "Canada", countryCode: "CA", timezoneIdentifier: "America/Montreal"),
        .init(name: "Calgary", country: "Canada", countryCode: "CA", timezoneIdentifier: "America/Edmonton"),
        .init(name: "Halifax", country: "Canada", countryCode: "CA", timezoneIdentifier: "America/Halifax"),

        .init(name: "Mexico City", country: "Mexico", countryCode: "MX", timezoneIdentifier: "America/Mexico_City"),
        .init(name: "Cancun", country: "Mexico", countryCode: "MX", timezoneIdentifier: "America/Cancun"),

        .init(name: "São Paulo", country: "Brazil", countryCode: "BR", timezoneIdentifier: "America/Sao_Paulo"),
        .init(name: "Rio de Janeiro", country: "Brazil", countryCode: "BR", timezoneIdentifier: "America/Sao_Paulo"),
        .init(name: "Brasilia", country: "Brazil", countryCode: "BR", timezoneIdentifier: "America/Sao_Paulo"),

        .init(name: "Buenos Aires", country: "Argentina", countryCode: "AR", timezoneIdentifier: "America/Argentina/Buenos_Aires"),
        .init(name: "Santiago", country: "Chile", countryCode: "CL", timezoneIdentifier: "America/Santiago"),
        .init(name: "Lima", country: "Peru", countryCode: "PE", timezoneIdentifier: "America/Lima"),
        .init(name: "Bogota", country: "Colombia", countryCode: "CO", timezoneIdentifier: "America/Bogota"),
        .init(name: "Caracas", country: "Venezuela", countryCode: "VE", timezoneIdentifier: "America/Caracas"),
        .init(name: "Quito", country: "Ecuador", countryCode: "EC", timezoneIdentifier: "America/Guayaquil"),
        .init(name: "La Paz", country: "Bolivia", countryCode: "BO", timezoneIdentifier: "America/La_Paz"),
        .init(name: "Montevideo", country: "Uruguay", countryCode: "UY", timezoneIdentifier: "America/Montevideo"),
        .init(name: "Asuncion", country: "Paraguay", countryCode: "PY", timezoneIdentifier: "America/Asuncion"),
        .init(name: "Panama City", country: "Panama", countryCode: "PA", timezoneIdentifier: "America/Panama"),
        .init(name: "San José", country: "Costa Rica", countryCode: "CR", timezoneIdentifier: "America/Costa_Rica"),
        .init(name: "Havana", country: "Cuba", countryCode: "CU", timezoneIdentifier: "America/Havana"),
        .init(name: "Kingston", country: "Jamaica", countryCode: "JM", timezoneIdentifier: "America/Jamaica"),
        .init(name: "San Juan", country: "Puerto Rico", countryCode: "PR", timezoneIdentifier: "America/Puerto_Rico"),

        // Europe
        .init(name: "London", country: "United Kingdom", countryCode: "GB", timezoneIdentifier: "Europe/London"),
        .init(name: "Edinburgh", country: "United Kingdom", countryCode: "GB", timezoneIdentifier: "Europe/London"),
        .init(name: "Dublin", country: "Ireland", countryCode: "IE", timezoneIdentifier: "Europe/Dublin"),
        .init(name: "Paris", country: "France", countryCode: "FR", timezoneIdentifier: "Europe/Paris"),
        .init(name: "Berlin", country: "Germany", countryCode: "DE", timezoneIdentifier: "Europe/Berlin"),
        .init(name: "Munich", country: "Germany", countryCode: "DE", timezoneIdentifier: "Europe/Berlin"),
        .init(name: "Frankfurt", country: "Germany", countryCode: "DE", timezoneIdentifier: "Europe/Berlin"),
        .init(name: "Hamburg", country: "Germany", countryCode: "DE", timezoneIdentifier: "Europe/Berlin"),
        .init(name: "Madrid", country: "Spain", countryCode: "ES", timezoneIdentifier: "Europe/Madrid"),
        .init(name: "Barcelona", country: "Spain", countryCode: "ES", timezoneIdentifier: "Europe/Madrid"),
        .init(name: "Rome", country: "Italy", countryCode: "IT", timezoneIdentifier: "Europe/Rome"),
        .init(name: "Milan", country: "Italy", countryCode: "IT", timezoneIdentifier: "Europe/Rome"),
        .init(name: "Amsterdam", country: "Netherlands", countryCode: "NL", timezoneIdentifier: "Europe/Amsterdam"),
        .init(name: "Brussels", country: "Belgium", countryCode: "BE", timezoneIdentifier: "Europe/Brussels"),
        .init(name: "Vienna", country: "Austria", countryCode: "AT", timezoneIdentifier: "Europe/Vienna"),
        .init(name: "Zurich", country: "Switzerland", countryCode: "CH", timezoneIdentifier: "Europe/Zurich"),
        .init(name: "Geneva", country: "Switzerland", countryCode: "CH", timezoneIdentifier: "Europe/Zurich"),
        .init(name: "Copenhagen", country: "Denmark", countryCode: "DK", timezoneIdentifier: "Europe/Copenhagen"),
        .init(name: "Stockholm", country: "Sweden", countryCode: "SE", timezoneIdentifier: "Europe/Stockholm"),
        .init(name: "Oslo", country: "Norway", countryCode: "NO", timezoneIdentifier: "Europe/Oslo"),
        .init(name: "Helsinki", country: "Finland", countryCode: "FI", timezoneIdentifier: "Europe/Helsinki"),
        .init(name: "Reykjavik", country: "Iceland", countryCode: "IS", timezoneIdentifier: "Atlantic/Reykjavik"),
        .init(name: "Lisbon", country: "Portugal", countryCode: "PT", timezoneIdentifier: "Europe/Lisbon"),
        .init(name: "Athens", country: "Greece", countryCode: "GR", timezoneIdentifier: "Europe/Athens"),
        .init(name: "Warsaw", country: "Poland", countryCode: "PL", timezoneIdentifier: "Europe/Warsaw"),
        .init(name: "Prague", country: "Czech Republic", countryCode: "CZ", timezoneIdentifier: "Europe/Prague"),
        .init(name: "Budapest", country: "Hungary", countryCode: "HU", timezoneIdentifier: "Europe/Budapest"),
        .init(name: "Bucharest", country: "Romania", countryCode: "RO", timezoneIdentifier: "Europe/Bucharest"),
        .init(name: "Sofia", country: "Bulgaria", countryCode: "BG", timezoneIdentifier: "Europe/Sofia"),
        .init(name: "Belgrade", country: "Serbia", countryCode: "RS", timezoneIdentifier: "Europe/Belgrade"),
        .init(name: "Zagreb", country: "Croatia", countryCode: "HR", timezoneIdentifier: "Europe/Zagreb"),
        .init(name: "Ljubljana", country: "Slovenia", countryCode: "SI", timezoneIdentifier: "Europe/Ljubljana"),
        .init(name: "Bratislava", country: "Slovakia", countryCode: "SK", timezoneIdentifier: "Europe/Bratislava"),
        .init(name: "Tallinn", country: "Estonia", countryCode: "EE", timezoneIdentifier: "Europe/Tallinn"),
        .init(name: "Riga", country: "Latvia", countryCode: "LV", timezoneIdentifier: "Europe/Riga"),
        .init(name: "Vilnius", country: "Lithuania", countryCode: "LT", timezoneIdentifier: "Europe/Vilnius"),
        .init(name: "Kyiv", country: "Ukraine", countryCode: "UA", timezoneIdentifier: "Europe/Kyiv"),
        .init(name: "Moscow", country: "Russia", countryCode: "RU", timezoneIdentifier: "Europe/Moscow"),
        .init(name: "St. Petersburg", country: "Russia", countryCode: "RU", timezoneIdentifier: "Europe/Moscow"),
        .init(name: "Istanbul", country: "Turkey", countryCode: "TR", timezoneIdentifier: "Europe/Istanbul"),
        .init(name: "Luxembourg", country: "Luxembourg", countryCode: "LU", timezoneIdentifier: "Europe/Luxembourg"),
        .init(name: "Monaco", country: "Monaco", countryCode: "MC", timezoneIdentifier: "Europe/Monaco"),
        .init(name: "Malta", country: "Malta", countryCode: "MT", timezoneIdentifier: "Europe/Malta"),

        // Middle East
        .init(name: "Dubai", country: "United Arab Emirates", countryCode: "AE", timezoneIdentifier: "Asia/Dubai"),
        .init(name: "Abu Dhabi", country: "United Arab Emirates", countryCode: "AE", timezoneIdentifier: "Asia/Dubai"),
        .init(name: "Doha", country: "Qatar", countryCode: "QA", timezoneIdentifier: "Asia/Qatar"),
        .init(name: "Riyadh", country: "Saudi Arabia", countryCode: "SA", timezoneIdentifier: "Asia/Riyadh"),
        .init(name: "Jeddah", country: "Saudi Arabia", countryCode: "SA", timezoneIdentifier: "Asia/Riyadh"),
        .init(name: "Kuwait City", country: "Kuwait", countryCode: "KW", timezoneIdentifier: "Asia/Kuwait"),
        .init(name: "Manama", country: "Bahrain", countryCode: "BH", timezoneIdentifier: "Asia/Bahrain"),
        .init(name: "Muscat", country: "Oman", countryCode: "OM", timezoneIdentifier: "Asia/Muscat"),
        .init(name: "Tehran", country: "Iran", countryCode: "IR", timezoneIdentifier: "Asia/Tehran"),
        .init(name: "Baghdad", country: "Iraq", countryCode: "IQ", timezoneIdentifier: "Asia/Baghdad"),
        .init(name: "Jerusalem", country: "Israel", countryCode: "IL", timezoneIdentifier: "Asia/Jerusalem"),
        .init(name: "Tel Aviv", country: "Israel", countryCode: "IL", timezoneIdentifier: "Asia/Jerusalem"),
        .init(name: "Amman", country: "Jordan", countryCode: "JO", timezoneIdentifier: "Asia/Amman"),
        .init(name: "Beirut", country: "Lebanon", countryCode: "LB", timezoneIdentifier: "Asia/Beirut"),
        .init(name: "Damascus", country: "Syria", countryCode: "SY", timezoneIdentifier: "Asia/Damascus"),

        // Asia
        .init(name: "Tokyo", country: "Japan", countryCode: "JP", timezoneIdentifier: "Asia/Tokyo"),
        .init(name: "Osaka", country: "Japan", countryCode: "JP", timezoneIdentifier: "Asia/Tokyo"),
        .init(name: "Kyoto", country: "Japan", countryCode: "JP", timezoneIdentifier: "Asia/Tokyo"),
        .init(name: "Seoul", country: "South Korea", countryCode: "KR", timezoneIdentifier: "Asia/Seoul"),
        .init(name: "Busan", country: "South Korea", countryCode: "KR", timezoneIdentifier: "Asia/Seoul"),
        .init(name: "Pyongyang", country: "North Korea", countryCode: "KP", timezoneIdentifier: "Asia/Pyongyang"),
        .init(name: "Beijing", country: "China", countryCode: "CN", timezoneIdentifier: "Asia/Shanghai"),
        .init(name: "Shanghai", country: "China", countryCode: "CN", timezoneIdentifier: "Asia/Shanghai"),
        .init(name: "Shenzhen", country: "China", countryCode: "CN", timezoneIdentifier: "Asia/Shanghai"),
        .init(name: "Guangzhou", country: "China", countryCode: "CN", timezoneIdentifier: "Asia/Shanghai"),
        .init(name: "Hong Kong", country: "Hong Kong", countryCode: "HK", timezoneIdentifier: "Asia/Hong_Kong"),
        .init(name: "Macau", country: "Macau", countryCode: "MO", timezoneIdentifier: "Asia/Macau"),
        .init(name: "Taipei", country: "Taiwan", countryCode: "TW", timezoneIdentifier: "Asia/Taipei"),
        .init(name: "Singapore", country: "Singapore", countryCode: "SG", timezoneIdentifier: "Asia/Singapore"),
        .init(name: "Kuala Lumpur", country: "Malaysia", countryCode: "MY", timezoneIdentifier: "Asia/Kuala_Lumpur"),
        .init(name: "Bangkok", country: "Thailand", countryCode: "TH", timezoneIdentifier: "Asia/Bangkok"),
        .init(name: "Jakarta", country: "Indonesia", countryCode: "ID", timezoneIdentifier: "Asia/Jakarta"),
        .init(name: "Bali", country: "Indonesia", countryCode: "ID", timezoneIdentifier: "Asia/Makassar"),
        .init(name: "Manila", country: "Philippines", countryCode: "PH", timezoneIdentifier: "Asia/Manila"),
        .init(name: "Hanoi", country: "Vietnam", countryCode: "VN", timezoneIdentifier: "Asia/Ho_Chi_Minh"),
        .init(name: "Ho Chi Minh City", country: "Vietnam", countryCode: "VN", timezoneIdentifier: "Asia/Ho_Chi_Minh"),
        .init(name: "Phnom Penh", country: "Cambodia", countryCode: "KH", timezoneIdentifier: "Asia/Phnom_Penh"),
        .init(name: "Vientiane", country: "Laos", countryCode: "LA", timezoneIdentifier: "Asia/Vientiane"),
        .init(name: "Yangon", country: "Myanmar", countryCode: "MM", timezoneIdentifier: "Asia/Yangon"),
        .init(name: "Dhaka", country: "Bangladesh", countryCode: "BD", timezoneIdentifier: "Asia/Dhaka"),
        .init(name: "Kathmandu", country: "Nepal", countryCode: "NP", timezoneIdentifier: "Asia/Kathmandu"),
        .init(name: "Colombo", country: "Sri Lanka", countryCode: "LK", timezoneIdentifier: "Asia/Colombo"),
        .init(name: "Mumbai", country: "India", countryCode: "IN", timezoneIdentifier: "Asia/Kolkata"),
        .init(name: "New Delhi", country: "India", countryCode: "IN", timezoneIdentifier: "Asia/Kolkata"),
        .init(name: "Bangalore", country: "India", countryCode: "IN", timezoneIdentifier: "Asia/Kolkata"),
        .init(name: "Chennai", country: "India", countryCode: "IN", timezoneIdentifier: "Asia/Kolkata"),
        .init(name: "Kolkata", country: "India", countryCode: "IN", timezoneIdentifier: "Asia/Kolkata"),
        .init(name: "Hyderabad", country: "India", countryCode: "IN", timezoneIdentifier: "Asia/Kolkata"),
        .init(name: "Karachi", country: "Pakistan", countryCode: "PK", timezoneIdentifier: "Asia/Karachi"),
        .init(name: "Lahore", country: "Pakistan", countryCode: "PK", timezoneIdentifier: "Asia/Karachi"),
        .init(name: "Islamabad", country: "Pakistan", countryCode: "PK", timezoneIdentifier: "Asia/Karachi"),
        .init(name: "Kabul", country: "Afghanistan", countryCode: "AF", timezoneIdentifier: "Asia/Kabul"),
        .init(name: "Tashkent", country: "Uzbekistan", countryCode: "UZ", timezoneIdentifier: "Asia/Tashkent"),
        .init(name: "Almaty", country: "Kazakhstan", countryCode: "KZ", timezoneIdentifier: "Asia/Almaty"),
        .init(name: "Baku", country: "Azerbaijan", countryCode: "AZ", timezoneIdentifier: "Asia/Baku"),
        .init(name: "Tbilisi", country: "Georgia", countryCode: "GE", timezoneIdentifier: "Asia/Tbilisi"),
        .init(name: "Yerevan", country: "Armenia", countryCode: "AM", timezoneIdentifier: "Asia/Yerevan"),
        .init(name: "Ulaanbaatar", country: "Mongolia", countryCode: "MN", timezoneIdentifier: "Asia/Ulaanbaatar"),

        // Oceania
        .init(name: "Sydney", country: "Australia", countryCode: "AU", timezoneIdentifier: "Australia/Sydney"),
        .init(name: "Melbourne", country: "Australia", countryCode: "AU", timezoneIdentifier: "Australia/Melbourne"),
        .init(name: "Brisbane", country: "Australia", countryCode: "AU", timezoneIdentifier: "Australia/Brisbane"),
        .init(name: "Perth", country: "Australia", countryCode: "AU", timezoneIdentifier: "Australia/Perth"),
        .init(name: "Adelaide", country: "Australia", countryCode: "AU", timezoneIdentifier: "Australia/Adelaide"),
        .init(name: "Canberra", country: "Australia", countryCode: "AU", timezoneIdentifier: "Australia/Sydney"),
        .init(name: "Hobart", country: "Australia", countryCode: "AU", timezoneIdentifier: "Australia/Hobart"),
        .init(name: "Darwin", country: "Australia", countryCode: "AU", timezoneIdentifier: "Australia/Darwin"),
        .init(name: "Auckland", country: "New Zealand", countryCode: "NZ", timezoneIdentifier: "Pacific/Auckland"),
        .init(name: "Wellington", country: "New Zealand", countryCode: "NZ", timezoneIdentifier: "Pacific/Auckland"),
        .init(name: "Christchurch", country: "New Zealand", countryCode: "NZ", timezoneIdentifier: "Pacific/Auckland"),
        .init(name: "Suva", country: "Fiji", countryCode: "FJ", timezoneIdentifier: "Pacific/Fiji"),
        .init(name: "Port Moresby", country: "Papua New Guinea", countryCode: "PG", timezoneIdentifier: "Pacific/Port_Moresby"),

        // Coordinated Universal Time
        .init(name: "UTC", country: "Coordinated Universal Time", countryCode: "UN", timezoneIdentifier: "UTC")
    ]

    static func search(_ query: String) -> [CityEntry] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let lower = trimmed.lowercased()
        return cities
            .filter { entry in
                entry.name.lowercased().contains(lower)
                    || entry.country.lowercased().contains(lower)
                    || entry.timezoneIdentifier.lowercased().contains(lower)
            }
            .sorted { lhs, rhs in
                let lhsStarts = lhs.name.lowercased().hasPrefix(lower)
                let rhsStarts = rhs.name.lowercased().hasPrefix(lower)
                if lhsStarts != rhsStarts { return lhsStarts && !rhsStarts }
                return lhs.name < rhs.name
            }
    }
}
