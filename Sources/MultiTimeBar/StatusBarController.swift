import AppKit
import SwiftUI
import Combine

/// Owns the `NSStatusItem` and the popover shown when it is clicked.
///
/// The status item's button image is rendered from `MenuBarLabelView` via
/// `ImageRenderer` on a short refresh cycle. This keeps the button a plain
/// `NSStatusBarButton` so clicks are dispatched natively through
/// `target`/`action`, avoiding the SwiftUI-vs-AppKit hit-testing pitfalls that
/// prevent popover activation when a hosting view is embedded as a subview.
@MainActor
final class StatusBarController {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let settings: AppSettings
    private let clockStore: ClockStore
    private let timeTravel: TimeTravelState
    private var eventMonitor: Any?
    private var cancellables: Set<AnyCancellable> = []
    private var refreshTimer: Timer?
    private var appearanceObservation: NSKeyValueObservation?

    init(settings: AppSettings, clockStore: ClockStore, timeTravel: TimeTravelState) {
        self.settings = settings
        self.clockStore = clockStore
        self.timeTravel = timeTravel
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        self.popover = NSPopover()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.contentViewController = NSHostingController(
            rootView: MenuBarContentView()
                .environmentObject(settings)
                .environmentObject(clockStore)
                .environmentObject(timeTravel)
        )

        if let button = statusItem.button {
            button.imagePosition = .imageOnly
            button.image = NSImage(
                systemSymbolName: "clock.badge",
                accessibilityDescription: "MultiTimeBar"
            )
            button.image?.isTemplate = true
            button.target = self
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        refreshLabel()

        // Refresh the rendered label each second so times tick. The timer runs
        // on the main run loop; observable stores also trigger a redraw so
        // toggles in Settings are reflected immediately.
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.refreshLabel() }
        }
        refreshTimer?.tolerance = 0.2

        Publishers.MergeMany(
            settings.objectWillChange.map { _ in () }.eraseToAnyPublisher(),
            clockStore.objectWillChange.map { _ in () }.eraseToAnyPublisher(),
            timeTravel.objectWillChange.map { _ in () }.eraseToAnyPublisher()
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] in self?.refreshLabel() }
        .store(in: &cancellables)

        // Repaint the rendered label when the menu bar's effective appearance
        // flips (e.g. system Dark Mode toggle), so the text stays legible.
        if let button = statusItem.button {
            appearanceObservation = button.observe(\.effectiveAppearance, options: [.new]) { [weak self] _, _ in
                Task { @MainActor [weak self] in self?.refreshLabel() }
            }
        }
    }

    deinit {
        refreshTimer?.invalidate()
        appearanceObservation?.invalidate()
    }

    private func refreshLabel() {
        // Match the label's color scheme to the status button's effective
        // appearance so `Color(nsColor: .labelColor)` resolves to the right
        // shade under the current menu bar tint (light wallpaper → black,
        // dark wallpaper / Dark Mode → white).
        let appearance = statusItem.button?.effectiveAppearance ?? NSApp.effectiveAppearance
        let isDark = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua

        let labelRoot = MenuBarLabelView()
            .environmentObject(settings)
            .environmentObject(clockStore)
            .environmentObject(timeTravel)
            .environment(\.colorScheme, isDark ? .dark : .light)
        let renderer = ImageRenderer(content: labelRoot)
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 2.0
        // isOpaque = false keeps the transparent status-bar background.
        renderer.isOpaque = false

        // Resolve NSColor-backed SwiftUI colors against the correct appearance.
        var image: NSImage?
        appearance.performAsCurrentDrawingAppearance {
            image = renderer.nsImage
        }
        guard let image else { return }
        // Color emoji (flags) must be preserved — do not treat as template.
        image.isTemplate = false
        statusItem.button?.image = image
        statusItem.length = max(image.size.width, NSStatusItem.squareLength)
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        NSLog("MultiTimeBar: togglePopover fired sender=\(String(describing: sender))")
        if popover.isShown {
            closePopover(sender)
        } else {
            openPopover(sender)
        }
    }

    private func openPopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else {
            NSLog("MultiTimeBar: openPopover — no button")
            return
        }
        NSLog("MultiTimeBar: openPopover showing")
        // Activating the app first ensures the popover reliably becomes key
        // and renders its content on macOS 14+ / macOS 26.
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()

        // Dismiss when the user clicks outside the popover.
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor [weak self] in self?.closePopover(nil) }
        }
    }

    private func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}
