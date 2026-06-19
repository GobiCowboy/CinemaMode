import AppKit
import Foundation
import CinemaModeCore

@MainActor
final class SystemEscapeKeyMonitor: EscapeKeyMonitoring {
    private let logger: SystemLogger
    private var localMonitor: Any?
    private var globalMonitor: Any?
    private var onEscape: (@Sendable () -> Void)?
    private var lastHandledTimestamp: TimeInterval = -1

    init(logger: SystemLogger) {
        self.logger = logger
    }

    func start(onEscape: @escaping @Sendable () -> Void) throws {
        stop()
        self.onEscape = onEscape

        let mask: NSEvent.EventTypeMask = [.keyDown]

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handle(event: event)
            return event
        }

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] event in
            Task { @MainActor in
                self?.handle(event: event)
            }
        }

        guard localMonitor != nil || globalMonitor != nil else {
            self.onEscape = nil
            throw AppError.escapeMonitorFailed("Unable to register escape key monitor")
        }

        logger.info(
            module: "keyboard",
            action: "monitor.start",
            message: "Escape key monitor started",
            context: nil
        )
    }

    func stop() {
        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }

        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }

        onEscape = nil
        lastHandledTimestamp = -1

        logger.info(
            module: "keyboard",
            action: "monitor.stop",
            message: "Escape key monitor stopped",
            context: nil
        )
    }

    private func handle(event: NSEvent) {
        guard event.type == .keyDown, event.keyCode == 53 else {
            return
        }

        if lastHandledTimestamp >= 0, abs(event.timestamp - lastHandledTimestamp) < 0.05 {
            return
        }

        lastHandledTimestamp = event.timestamp

        logger.info(
            module: "keyboard",
            action: "escape.tap",
            message: "Escape key pressed",
            context: nil
        )
        onEscape?()
    }
}
