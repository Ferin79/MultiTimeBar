import SwiftUI
import AppKit

@main
struct MultiTimeBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // SwiftUI requires at least one Scene; we use a hidden settings scene
        // as a placeholder while managing our real windows via AppDelegate.
        Settings {
            EmptyView()
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    static private(set) weak var shared: AppDelegate?

    let settings = AppSettings()
    let clockStore = ClockStore()
    let timeTravel = TimeTravelState()

    private var statusBarController: StatusBarController?
    private var settingsWindow: NSWindow?
    private var timeTravelWindow: NSWindow?

    override init() {
        super.init()
        AppDelegate.shared = self
    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        // Prevent macOS from restoring windows (e.g. the SwiftUI Settings scene)
        // when the app is relaunched on login/reboot. This app is menu-bar only
        // and should never surface a window unless the user explicitly asks.
        UserDefaults.standard.set(false, forKey: "NSQuitAlwaysKeepsWindows")
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusBarController = StatusBarController(
            settings: settings,
            clockStore: clockStore,
            timeTravel: timeTravel
        )

        // Close any windows that SwiftUI or state restoration may have opened
        // during launch (in particular the placeholder Settings scene window).
        // We defer to the next run loop tick so SwiftUI has finished creating
        // its scenes before we sweep them away.
        DispatchQueue.main.async {
            for window in NSApp.windows where window !== self.settingsWindow && window !== self.timeTravelWindow {
                window.close()
            }
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Clicking the app icon (e.g. from Login Items) must not pop a window.
        return false
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return false
    }

    func openSettings() {
        NSLog("MultiTimeBar: openSettings tapped")
        NSApp.activate(ignoringOtherApps: true)
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            return
        }
        settingsWindow = makeWindow(
            title: "Settings",
            size: NSSize(width: 640, height: 460),
            rootView: SettingsView()
                .environmentObject(settings)
                .environmentObject(clockStore)
        )
    }

    func openTimeTravel() {
        NSLog("MultiTimeBar: openTimeTravel tapped")
        NSApp.activate(ignoringOtherApps: true)
        if let window = timeTravelWindow {
            window.makeKeyAndOrderFront(nil)
            return
        }
        timeTravelWindow = makeWindow(
            title: "Time Travel",
            size: NSSize(width: 460, height: 480),
            rootView: TimeTravelView()
                .environmentObject(settings)
                .environmentObject(clockStore)
                .environmentObject(timeTravel)
        )
    }

    private func makeWindow<Content: View>(
        title: String,
        size: NSSize,
        rootView: Content
    ) -> NSWindow {
        let hosting = NSHostingController(rootView: rootView)

        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = title
        window.isReleasedWhenClosed = false
        window.contentViewController = hosting
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        return window
    }
}
