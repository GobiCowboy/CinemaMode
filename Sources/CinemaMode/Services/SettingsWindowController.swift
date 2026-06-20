import AppKit
import SwiftUI
import CinemaModeCore

@MainActor
final class SettingsWindowController {
    private let preferences: PreferencesStore
    private let edition: AppEdition
    private var window: NSWindow?

    init(preferences: PreferencesStore, edition: AppEdition) {
        self.preferences = preferences
        self.edition = edition
    }

    func show() {
        openSettings()
    }

    func openSettings() {
        let copy = CinemaModeCopy(language: preferences.preferredLanguage)
        if let window {
            window.title = copy.settingsTitle
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let contentView = SettingsView(preferences: preferences, edition: edition)
        let hostingController = NSHostingController(rootView: contentView)
        let window = NSWindow(
            contentViewController: hostingController
        )
        window.title = copy.settingsTitle
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
