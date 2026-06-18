import AppKit
import Foundation
import CinemaModeCore

@MainActor
final class SystemPresentationController: PresentationControlling {
    private let logger: SystemLogger
    private var activationAnchorWindow: NSWindow?

    init(logger: SystemLogger) {
        self.logger = logger
    }

    func captureSnapshot() throws -> PresentationSnapshot {
        let options = NSApp.presentationOptions.rawValue
        let snapshot = PresentationSnapshot(presentationOptionsRawValue: options)
        logger.info(
            module: "presentation",
            action: "snapshot.capture",
            message: "Presentation snapshot captured",
            context: ["optionsRawValue": "\(options)"]
        )
        return snapshot
    }

    func applyCinemaMode(using snapshot: PresentationSnapshot) throws {
        let activationBefore = String(describing: NSApp.activationPolicy())
        let frontmostBefore = NSWorkspace.shared.frontmostApplication?.localizedName ?? "unknown"
        let anchorWindow = makeActivationAnchorWindow()
        positionActivationAnchorWindow(anchorWindow)
        anchorWindow.orderFrontRegardless()

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        let options: NSApplication.PresentationOptions = [.autoHideMenuBar, .autoHideDock]
        NSApp.presentationOptions = options
        logger.info(
            module: "presentation",
            action: "options.apply",
            message: "Cinema presentation options applied",
            context: [
                "activationBefore": activationBefore,
                "activationAfter": String(describing: NSApp.activationPolicy()),
                "actualOptionsRawValue": "\(NSApp.presentationOptions.rawValue)",
                "anchorFrame": NSStringFromRect(anchorWindow.frame),
                "frontmostAfter": NSWorkspace.shared.frontmostApplication?.localizedName ?? "unknown",
                "frontmostBefore": frontmostBefore,
                "optionsRawValue": "\(options.rawValue)",
                "originalOptionsRawValue": "\(snapshot.presentationOptionsRawValue)"
            ]
        )
    }

    func restore(from snapshot: PresentationSnapshot) throws {
        let restored = NSApplication.PresentationOptions(rawValue: snapshot.presentationOptionsRawValue)
        NSApp.presentationOptions = restored
        activationAnchorWindow?.orderOut(nil)
        activationAnchorWindow = nil
        NSApp.setActivationPolicy(.accessory)
    }

    private func makeActivationAnchorWindow() -> NSWindow {
        if let activationAnchorWindow {
            return activationAnchorWindow
        }

        let window = ActivationAnchorWindow(
            contentRect: CGRect(x: 0, y: 0, width: 1, height: 1),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.backgroundColor = .clear
        window.isOpaque = false
        window.alphaValue = 0.01
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.level = .statusBar
        window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary, .transient, .ignoresCycle]
        activationAnchorWindow = window
        return window
    }

    private func positionActivationAnchorWindow(_ window: NSWindow) {
        let mouseLocation = NSEvent.mouseLocation
        let targetScreen = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) })
            ?? NSScreen.main
            ?? NSScreen.screens.first

        let screenFrame = targetScreen?.frame ?? .zero
        let origin = CGPoint(
            x: min(max(mouseLocation.x, screenFrame.minX), screenFrame.maxX - 1),
            y: min(max(mouseLocation.y, screenFrame.minY), screenFrame.maxY - 1)
        )

        window.setFrame(CGRect(origin: origin, size: CGSize(width: 1, height: 1)), display: false)
    }
}

private final class ActivationAnchorWindow: NSWindow {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
