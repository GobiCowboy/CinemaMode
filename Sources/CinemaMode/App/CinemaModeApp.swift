import SwiftUI

@main
struct CinemaModeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var environment = AppEnvironment()

    var body: some Scene {
        WindowGroup("Cinema Mode", id: "main") {
            MainControlView(service: environment.service)
        }
    }
}
