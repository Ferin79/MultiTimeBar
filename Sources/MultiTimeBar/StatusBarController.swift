import AppKit
import SwiftUI
import Combine

/// Owns the `NSStatusItem` and the popover shown when it is clicked.
///
/// We use `NSStatusItem` directly (rather than SwiftUI's `MenuBarExtra`) because
/// `MenuBarExtra` does not reliably display when the executable is bundled outside
/// of a full Xcode app target.
@MainActor
final class StatusBarController {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let hostingView: NSHostingView<AnyView>
    private var eventMonitor: Any?
    private var cancellables: Set<AnyCancellable> = []

    init(settings: AppSettings, clockStore: ClockStore, timeTravel: TimeTravelState) {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let labelRoot = MenuBarLabelView()
            .environmentObject(settings)
            .environmentObject(clockStore)
            .environmentObject(timeTravel)
        self.hostingView = NSHostingView(rootView: AnyView(labelRoot))
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        // Let SwiftUI report a real intrinsic size so the status item can match it.
        if #available(macOS 13.0, *) {
            hostingView.sizingOptions = [.intrinsicContentSize]
        }

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
            button.addSubview(hostingView)
            NSLayoutConstraint.activate([
                hostingView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
                hostingView.centerYAnchor.constraint(equalTo: button.centerYAnchor)
            ])
            button.target = self
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Ensure the status item resizes when the label's intrinsic width changes.
        NotificationCenter.default.publisher(for: NSView.frameDidChangeNotification, object: hostingView)
            .sink { [weak self] _ in self?.updateStatusItemLength() }
            .store(in: &cancellables)
        hostingView.postsFrameChangedNotifications = true
        updateStatusItemLength()
    }

    private func updateStatusItemLength() {
        let intrinsic = hostingView.intrinsicContentSize
        let fitting = hostingView.fittingSize
        let width = max(intrinsic.width, fitting.width)
        if width > 0 {
            statusItem.length = width
        }
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            openPopover(sender)
        }
    }

    private func openPopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()

        // Dismiss when the user clicks outside the popover.
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in self?.closePopover(nil) }
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
