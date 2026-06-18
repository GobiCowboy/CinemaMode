import SwiftUI

@main
struct CinemaModeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var environment = AppEnvironment()
    @State private var inserted = false

    var body: some Scene {
        MenuBarExtra(isInserted: $inserted) {
            EmptyView()
        } label: {
            EmptyView()
        }
    }
}
