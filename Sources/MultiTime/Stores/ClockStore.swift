import Foundation
import Combine

/// Persistent list of user-configured clocks.
@MainActor
final class ClockStore: ObservableObject {
    private let storageKey = "clocks.v1"

    @Published var clocks: [Clock] = [] {
        didSet { save() }
    }

    init() {
        load()
        if clocks.isEmpty {
            // Seed with the local time zone so first launch is not empty.
            let tz = TimeZone.current
            let identifier = tz.identifier
            let name = identifier.components(separatedBy: "/").last?.replacingOccurrences(of: "_", with: " ") ?? "Local"
            let countryCode = Locale.current.region?.identifier
                ?? TimezoneDatabase.cities.first { $0.timezoneIdentifier == identifier }?.countryCode
                ?? "UN"
            clocks = [Clock(label: name, timezoneIdentifier: identifier, countryCode: countryCode)]
        }
    }

    func add(_ entry: CityEntry) {
        let clock = Clock(
            label: entry.name,
            timezoneIdentifier: entry.timezoneIdentifier,
            countryCode: entry.countryCode
        )
        clocks.append(clock)
    }

    func remove(_ clock: Clock) {
        clocks.removeAll { $0.id == clock.id }
    }

    func move(from source: IndexSet, to destination: Int) {
        clocks.move(fromOffsets: source, toOffset: destination)
    }

    func update(_ clock: Clock) {
        guard let idx = clocks.firstIndex(where: { $0.id == clock.id }) else { return }
        clocks[idx] = clock
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        if let decoded = try? JSONDecoder().decode([Clock].self, from: data) {
            // Assign without triggering save().
            self.clocks = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(clocks) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
