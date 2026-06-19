import AppKit
import Foundation
import CinemaModeCore

@MainActor
final class SystemPresentationController: PresentationControlling {
    private let logger: SystemLogger
    private var chromeCoverPanels: [NSPanel] = []
    private var observers: [NSObjectProtocol] = []
    private var lastExternalFrontmostApplication: NSRunningApplication?

    init(logger: SystemLogger) {
        self.logger = logger
        rememberExternalFrontmostApplication(NSWorkspace.shared.frontmostApplication, shouldLog: false)
        observeApplicationActivation()
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
        let frontmostBefore = NSWorkspace.shared.frontmostApplication
        let focusTarget = preferredExternalFocusTarget(currentFrontmost: frontmostBefore)
        logPresentationDiagnostics(stage: "beforeCover")

        showChromeCovers()
        let restoredExternalFocus = restoreExternalFocusIfNeeded(focusTarget)

        logger.info(
            module: "presentation",
            action: "overlay.apply",
            message: "Cinema overlay applied without activating the app",
            context: [
                "activationPolicy": String(describing: NSApp.activationPolicy()),
                "currentSystemOptionsRawValue": "\(NSApp.currentSystemPresentationOptions.rawValue)",
                "focusTarget": applicationSummary(focusTarget),
                "frontmostAfter": applicationSummary(NSWorkspace.shared.frontmostApplication),
                "frontmostBefore": applicationSummary(frontmostBefore),
                "isActive": "\(NSApp.isActive)",
                "originalOptionsRawValue": "\(snapshot.presentationOptionsRawValue)",
                "presentationOptionsRawValue": "\(NSApp.presentationOptions.rawValue)",
                "restoredExternalFocus": "\(restoredExternalFocus)"
            ]
        )
        logPresentationDiagnostics(stage: "afterCoverImmediate")
        scheduleDeferredDiagnostics()
    }

    func restore(from snapshot: PresentationSnapshot) throws {
        logPresentationDiagnostics(stage: "beforeRestore")
        hideChromeCovers()
        let restored = NSApplication.PresentationOptions(rawValue: snapshot.presentationOptionsRawValue)
        if NSApp.presentationOptions.rawValue != snapshot.presentationOptionsRawValue {
            NSApp.presentationOptions = restored
        }
        logPresentationDiagnostics(stage: "afterRestore")
    }

    private func showChromeCovers() {
        hideChromeCovers()

        chromeCoverPanels = NSScreen.screens.flatMap { screen in
            coverFrames(for: screen).map { frame in
                makeChromeCoverPanel(frame: frame)
            }
        }

        chromeCoverPanels.forEach { panel in
            panel.orderFrontRegardless()
        }

        logger.info(
            module: "presentation",
            action: "chromeCover.show",
            message: "System chrome cover panels shown",
            context: [
                "count": "\(chromeCoverPanels.count)",
                "frames": chromeCoverPanels.map { rectSummary($0.frame) }.joined(separator: "|")
            ]
        )
    }

    private func hideChromeCovers() {
        guard !chromeCoverPanels.isEmpty else {
            return
        }

        let count = chromeCoverPanels.count
        chromeCoverPanels.forEach { panel in
            panel.orderOut(nil)
        }
        chromeCoverPanels = []

        logger.info(
            module: "presentation",
            action: "chromeCover.hide",
            message: "System chrome cover panels hidden",
            context: ["count": "\(count)"]
        )
    }

    private func coverFrames(for screen: NSScreen) -> [CGRect] {
        let frame = screen.frame
        let visibleFrame = screen.visibleFrame
        var frames: [CGRect] = []

        let topHeight = max(0, frame.maxY - visibleFrame.maxY)
        if topHeight > 0 {
            frames.append(CGRect(x: frame.minX, y: visibleFrame.maxY, width: frame.width, height: topHeight))
        }

        let bottomHeight = max(0, visibleFrame.minY - frame.minY)
        if bottomHeight > 0 {
            frames.append(CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: bottomHeight))
        }

        let leftWidth = max(0, visibleFrame.minX - frame.minX)
        if leftWidth > 0 {
            frames.append(CGRect(x: frame.minX, y: frame.minY, width: leftWidth, height: frame.height))
        }

        let rightWidth = max(0, frame.maxX - visibleFrame.maxX)
        if rightWidth > 0 {
            frames.append(CGRect(x: visibleFrame.maxX, y: frame.minY, width: rightWidth, height: frame.height))
        }

        return frames
    }

    private func makeChromeCoverPanel(frame: CGRect) -> NSPanel {
        let panel = ChromeCoverPanel(
            contentRect: frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle]
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.backgroundColor = NSColor.black.withAlphaComponent(0.96)
        panel.isOpaque = false
        panel.hasShadow = false
        panel.ignoresMouseEvents = false
        return panel
    }

    private func observeApplicationActivation() {
        let center = NotificationCenter.default
        observers.append(center.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: NSApp,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.logPresentationDiagnostics(stage: "didBecomeActive")
            }
        })
        observers.append(center.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: NSApp,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.logPresentationDiagnostics(stage: "didResignActive")
            }
        })

        observers.append(NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let application = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            Task { @MainActor in
                self?.rememberExternalFrontmostApplication(application, shouldLog: true)
            }
        })
    }

    private func scheduleDeferredDiagnostics() {
        for delay in [0.25, 1.0, 2.0] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                Task { @MainActor in
                    self?.logPresentationDiagnostics(stage: "afterApply+\(delay)s")
                }
            }
        }
    }

    private func logPresentationDiagnostics(stage: String) {
        let context: [String: String] = [
            "activationPolicy": String(describing: NSApp.activationPolicy()),
            "currentSystemOptionsRawValue": "\(NSApp.currentSystemPresentationOptions.rawValue)",
            "frontmostApp": NSWorkspace.shared.frontmostApplication?.localizedName ?? "unknown",
            "isActive": "\(NSApp.isActive)",
            "keyWindow": windowSummary(NSApp.keyWindow),
            "mainWindow": windowSummary(NSApp.mainWindow),
            "presentationOptionsRawValue": "\(NSApp.presentationOptions.rawValue)",
            "screens": screenSummary(),
            "stage": stage,
            "windows": appWindowsSummary()
        ]

        logger.info(
            module: "presentation",
            action: "diagnostic.\(stage)",
            message: "Presentation diagnostic",
            context: context
        )
    }

    private func screenSummary() -> String {
        NSScreen.screens.enumerated()
            .map { index, screen in
                "\(index):frame=\(rectSummary(screen.frame)),visible=\(rectSummary(screen.visibleFrame))"
            }
            .joined(separator: "|")
    }

    private func appWindowsSummary() -> String {
        NSApp.windows.enumerated()
            .map { index, window in
                "\(index):\(windowSummary(window))"
            }
            .joined(separator: "|")
    }

    private func preferredExternalFocusTarget(currentFrontmost: NSRunningApplication?) -> NSRunningApplication? {
        if isExternalRegularApplication(currentFrontmost) {
            return currentFrontmost
        }

        return lastExternalFrontmostApplication
    }

    private func restoreExternalFocusIfNeeded(_ application: NSRunningApplication?) -> Bool {
        guard let application,
              isExternalRegularApplication(application),
              !application.isTerminated
        else {
            return false
        }

        let currentFrontmost = NSWorkspace.shared.frontmostApplication
        guard !isExternalRegularApplication(currentFrontmost) else {
            return false
        }

        return application.activate(options: [])
    }

    private func rememberExternalFrontmostApplication(_ application: NSRunningApplication?, shouldLog: Bool) {
        guard isExternalRegularApplication(application), let application else {
            return
        }

        lastExternalFrontmostApplication = application

        if shouldLog {
            logger.info(
                module: "presentation",
                action: "frontmost.remember",
                message: "Remembered external frontmost application",
                context: ["application": applicationSummary(application)]
            )
        }
    }

    private func isExternalRegularApplication(_ application: NSRunningApplication?) -> Bool {
        guard let application else {
            return false
        }

        return application.processIdentifier != ProcessInfo.processInfo.processIdentifier
            && application.activationPolicy == .regular
    }

    private func applicationSummary(_ application: NSRunningApplication?) -> String {
        guard let application else {
            return "nil"
        }

        return "\(application.localizedName ?? "unknown"),pid=\(application.processIdentifier),policy=\(application.activationPolicy.rawValue),terminated=\(application.isTerminated)"
    }

    private func windowSummary(_ window: NSWindow?) -> String {
        guard let window else {
            return "nil"
        }

        return "\(type(of: window)),visible=\(window.isVisible),key=\(window.isKeyWindow),main=\(window.isMainWindow),level=\(window.level.rawValue),frame=\(rectSummary(window.frame)),style=\(window.styleMask.rawValue),collection=\(window.collectionBehavior.rawValue)"
    }

    private func rectSummary(_ rect: CGRect) -> String {
        "x:\(Int(rect.origin.x)),y:\(Int(rect.origin.y)),w:\(Int(rect.width)),h:\(Int(rect.height))"
    }
}

private final class ChromeCoverPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
