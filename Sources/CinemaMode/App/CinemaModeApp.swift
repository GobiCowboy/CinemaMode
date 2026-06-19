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
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
