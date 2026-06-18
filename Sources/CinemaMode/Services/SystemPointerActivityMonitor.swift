import AppKit
import Foundation
import CinemaModeCore

@MainActor
final class SystemPointerActivityMonitor: PointerActivityMonitoring {
    private let logger: SystemLogger
    private var globalMonitor: Any?
    private var idleTimer: Timer?
    private var currentActivity: PointerActivity = .idle
    private var onChange: (@Sendable (PointerVisibilityState) -> Void)?

    init(logger: SystemLogger) {
        self.logger = logger
    }

    func start(onChange: @escaping @Sendable (PointerVisibilityState) -> Void) throws {
        stop()
        self.onChange = onChange
        currentActivity = .idle
        notify(activity: .idle)

        let mask: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged]
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] _ in
            Task { @MainActor in
                self?.registerMovement()
            }
        }

        if globalMonitor == nil {
            throw AppError.pointerMonitorFailed("Unable to register pointer activity monitor")
        }

        logger.info(
            module: "pointer",
            action: "monitor.start",
            message: "Pointer activity monitor started",
            context: nil
        )
    }

    func stop() {
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }
        idleTimer?.invalidate()
        idleTimer = nil
        currentActivity = .idle
        onChange = nil
        logger.info(
            module: "pointer",
            action: "monitor.stop",
            message: "Pointer activity monitor stopped",
            context: nil
        )
    }

    private func registerMovement() {
        guard currentActivity != .moving else {
            resetIdleTimer()
            return
        }

        currentActivity = .moving
        notify(activity: .moving)
        resetIdleTimer()
    }

    private func resetIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.transitionToIdle()
            }
        }
    }

    private func transitionToIdle() {
        guard currentActivity != .idle else {
            return
        }
        currentActivity = .idle
        notify(activity: .idle)
    }

    private func notify(activity: PointerActivity) {
        onChange?(PointerVisibilityState(activity: activity, lastMovedAt: activity == .moving ? Date() : nil))
    }
}

