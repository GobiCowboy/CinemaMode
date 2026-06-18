import SwiftUI

@main
struct CinemaModeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var environment = AppEnvironment()

    var body: some Scene {
        MenuBarExtra {
            MenuBarMenuView(service: environment.service)
        } label: {
            MenuBarIconView()
        }
    }
}
