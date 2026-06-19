import AppKit
import SwiftUI
import CinemaModeCore

@MainActor
final class SettingsWindowController {
    private let preferences: PreferencesStore
    private var window: NSWindow?

    init(preferences: PreferencesStore) {
        self.preferences = preferences
    }

    func show() {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let contentView = SettingsView(preferences: preferences)
        let hostingController = NSHostingController(rootView: contentView)
        let window = NSWindow(
            contentViewController: hostingController
        )
        window.title = "Cinema Mode Settings"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setContentSize(NSSize(width: 520, height: 460))
        window.center()
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.managed]
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.window = window
    }
}
