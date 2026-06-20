import AppKit

@MainActor
@main
final class CinemaModeApp: NSObject, NSApplicationDelegate {
    private static var retainedDelegate: CinemaModeApp?

    private var environment: AppEnvironment?

    static func main() {
        let app = NSApplication.shared
        let delegate = CinemaModeApp()
        retainedDelegate = delegate
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        environment = AppEnvironment()
        environment?.openSettings()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        environment?.openSettings()
        return false
    }
}
