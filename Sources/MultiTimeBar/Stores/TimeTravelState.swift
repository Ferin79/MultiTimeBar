import Foundation
import Combine

/// Optional offset (in seconds) applied to the "now" reference used by the menu bar clocks.
/// When zero (default), clocks display real time. The Time Travel planner adjusts this.
@MainActor
final class TimeTravelState: ObservableObject {
    @Published var offset: TimeInterval = 0
    @Published var isActive: Bool = false

    func reset() {
        offset = 0
        isActive = false
    }

    /// The reference "now" the app should display, given the current offset.
    var referenceDate: Date {
        Date().addingTimeInterval(isActive ? offset : 0)
    }
}
