import SwiftUI
import AppKit

@main
struct MultiTimeApp: App {
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

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusBarController = StatusBarController(
            settings: settings,
            clockStore: clockStore,
            timeTravel: timeTravel
        )
    }

    func openSettings() {
        NSLog("MultiTime: openSettings tapped")
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
        NSLog("MultiTime: openTimeTravel tapped")
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
