import Foundation
import SwiftUI
import Combine
import ServiceManagement

/// User-facing display and behavior preferences, persisted via `UserDefaults`.
@MainActor
final class AppSettings: ObservableObject {
    private enum Key {
        static let use24Hour = "use24Hour"
        static let showSeconds = "showSeconds"
        static let showFlags = "showFlags"
        static let showDayDifference = "showDayDifference"
        static let stackInTwoRows = "stackInTwoRows"
        static let showTimeTravel = "showTimeTravel"
        static let launchAtLogin = "launchAtLogin"
        static let hasInitialized = "hasInitialized"
    }

    @Published var use24Hour: Bool {
        didSet { UserDefaults.standard.set(use24Hour, forKey: Key.use24Hour) }
    }
    @Published var showSeconds: Bool {
        didSet { UserDefaults.standard.set(showSeconds, forKey: Key.showSeconds) }
    }
    @Published var showFlags: Bool {
        didSet { UserDefaults.standard.set(showFlags, forKey: Key.showFlags) }
    }
    @Published var showDayDifference: Bool {
        didSet { UserDefaults.standard.set(showDayDifference, forKey: Key.showDayDifference) }
    }
    @Published var stackInTwoRows: Bool {
        didSet { UserDefaults.standard.set(stackInTwoRows, forKey: Key.stackInTwoRows) }
    }
    @Published var showTimeTravel: Bool {
        didSet { UserDefaults.standard.set(showTimeTravel, forKey: Key.showTimeTravel) }
    }
    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: Key.launchAtLogin)
            applyLaunchAtLogin()
        }
    }

    init() {
        let defaults = UserDefaults.standard
        // Register sensible defaults on first launch.
        defaults.register(defaults: [
            Key.use24Hour: false,
            Key.showSeconds: true,
            Key.showFlags: true,
            Key.showDayDifference: true,
            Key.stackInTwoRows: false,
            Key.showTimeTravel: true,
            Key.launchAtLogin: true,
            Key.hasInitialized: false
        ])
        use24Hour = defaults.bool(forKey: Key.use24Hour)
        showSeconds = defaults.bool(forKey: Key.showSeconds)
        showFlags = defaults.bool(forKey: Key.showFlags)
        showDayDifference = defaults.bool(forKey: Key.showDayDifference)
        stackInTwoRows = defaults.bool(forKey: Key.stackInTwoRows)
        showTimeTravel = defaults.bool(forKey: Key.showTimeTravel)
        launchAtLogin = defaults.bool(forKey: Key.launchAtLogin)

        // Swift does not trigger `didSet` from initializer assignments, so
        // reconcile the SMAppService state ourselves on first launch.
        if !defaults.bool(forKey: Key.hasInitialized) {
            defaults.set(true, forKey: Key.hasInitialized)
            applyLaunchAtLogin()
        } else {
            // On later launches, keep the toggle in sync with the OS in case
            // the user removed the login item from System Settings.
            launchAtLogin = (SMAppService.mainApp.status == .enabled)
        }
    }

    private func applyLaunchAtLogin() {
        let service = SMAppService.mainApp
        do {
            if launchAtLogin {
                if service.status != .enabled {
                    try service.register()
                }
            } else {
                if service.status == .enabled {
                    try service.unregister()
                }
            }
        } catch {
            NSLog("MultiTime: failed to update login item registration: \(error.localizedDescription)")
        }
    }
}
