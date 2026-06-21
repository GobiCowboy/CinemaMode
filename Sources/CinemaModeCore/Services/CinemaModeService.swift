import Combine
import Foundation

@MainActor
public final class CinemaModeService: ObservableObject {
    @Published public private(set) var phase: CinemaModePhase = .idle
    @Published public private(set) var lastError: AppError?
    @Published public private(set) var enteredAt: Date?

    private let presentationController: any PresentationControlling
    private let environmentPreferencesController: any EnvironmentPreferencesControlling
    private let floatingPanelController: any FloatingPanelControlling
    private let pointerMonitor: any PointerActivityMonitoring
    private let preferencesStore: PreferencesStore
    private let logger: any CinemaModeLogging
    private let feedbackPresenter: (any CinemaModeFeedbackPresenting)?
    private let supportsDockAutoHide: Bool

    private var snapshot: PresentationSnapshot?
    private var environmentSnapshot: EnvironmentPreferencesSnapshot?

    public init(
        presentationController: any PresentationControlling,
        environmentPreferencesController: any EnvironmentPreferencesControlling,
        floatingPanelController: any FloatingPanelControlling,
        pointerMonitor: any PointerActivityMonitoring,
        preferencesStore: PreferencesStore,
        logger: any CinemaModeLogging = NullCinemaModeLogger(),
        feedbackPresenter: (any CinemaModeFeedbackPresenting)? = nil,
        supportsDockAutoHide: Bool = false
    ) {
        self.presentationController = presentationController
        self.environmentPreferencesController = environmentPreferencesController
        self.floatingPanelController = floatingPanelController
        self.pointerMonitor = pointerMonitor
        self.preferencesStore = preferencesStore
        self.logger = logger
        self.feedbackPresenter = feedbackPresenter
        self.supportsDockAutoHide = supportsDockAutoHide
    }

    public func enter() {
        if phase == .failed {
            recoverIfNeeded()
        }

        let effectiveAnchor = preferencesStore.preferredFloatingAnchor

        guard phase == .idle else {
            logger.warn(
                module: "cinemaMode",
                action: "enter.ignored",
                message: "Enter ignored because mode is not idle",
                context: ["phase": phase.rawValue]
            )
            return
        }

        phase = .entering
        lastError = nil

        logger.info(
            module: "cinemaMode",
            action: "enter.start",
            message: "Start entering cinema mode",
            context: ["anchor": effectiveAnchor.rawValue]
        )

        do {
            let capturedSnapshot = try presentationController.captureSnapshot()
            let capturedEnvironmentSnapshot = try environmentPreferencesController.captureSnapshot()
            snapshot = capturedSnapshot
            environmentSnapshot = capturedEnvironmentSnapshot

            try presentationController.applyCinemaMode(using: capturedSnapshot)
            try environmentPreferencesController.applyPreferences(
                from: preferencesStore,
                after: presentationController.transitionDelay(for: .enterEnvironment)
            )

            let windowState = FloatingWindowState(
                anchor: effectiveAnchor,
                opacity: 0.05,
                isHovered: false,
                isVisible: true
            )

            try floatingPanelController.show(state: windowState) { [weak self] in
                Task { @MainActor in
                    self?.exit()
                }
            }

            try pointerMonitor.start { [weak self] visibility in
                Task { @MainActor in
                    self?.handlePointerVisibilityChange(visibility)
                }
            }

            enteredAt = Date()
            phase = .active
            presentEnterFeedback()

            logger.info(
                module: "cinemaMode",
                action: "enter.success",
                message: "Cinema mode entered",
                context: [
                    "anchor": effectiveAnchor.rawValue,
                    "preferredVolume": "\(Int(preferencesStore.preferredVolume))"
                ]
            )
        } catch {
            handleEnterFailure(error)
        }
    }

    public func exit() {
        guard phase == .active || phase == .entering || phase == .failed else {
            logger.warn(
                module: "cinemaMode",
                action: "exit.ignored",
                message: "Exit ignored because mode is not active",
                context: ["phase": phase.rawValue]
            )
            return
        }

        phase = .exiting
        logger.info(
            module: "cinemaMode",
            action: "exit.start",
            message: "Start exiting cinema mode",
            context: ["phase": phase.rawValue]
        )

        stopRuntimeMonitors()
        floatingPanelController.hide()

        guard let currentSnapshot = snapshot else {
            presentExitFeedback()
            phase = .idle
            enteredAt = nil
            environmentSnapshot = nil
            lastError = nil
            logger.info(
                module: "cinemaMode",
                action: "exit.success",
                message: "Cinema mode exited",
                context: ["restored": "false"]
            )
            return
        }

        do {
            try presentationController.restore(from: currentSnapshot)
            if let environmentSnapshot {
                try environmentPreferencesController.restore(
                    from: environmentSnapshot,
                    preferences: preferencesStore,
                    after: presentationController.transitionDelay(for: .exitEnvironment)
                )
            }
            presentExitFeedback()
            snapshot = nil
            environmentSnapshot = nil
            enteredAt = nil
            lastError = nil
            phase = .idle

            logger.info(
                module: "presentation",
                action: "options.restore",
                message: "Presentation options restored",
                context: ["restoreAttemptCount": "\(currentSnapshot.restoreAttemptCount)"]
            )
            logger.info(
                module: "cinemaMode",
                action: "exit.success",
                message: "Cinema mode exited",
                context: ["restored": "true"]
            )
        } catch {
            phase = .failed
            lastError = .presentationRestoreFailed(error.localizedDescription)
            logger.error(
                module: "presentation",
                action: "options.restore.failed",
                message: "Failed to restore presentation options",
                error: error,
                context: ["restoreAttemptCount": "\(currentSnapshot.restoreAttemptCount)"]
            )
        }
    }

    public func recoverIfNeeded() {
        guard phase != .idle || snapshot != nil || environmentSnapshot != nil || floatingPanelController.isVisible else {
            return
        }

        phase = .recovering
        logger.warn(
            module: "cinemaMode",
            action: "recover",
            message: "Recovering inconsistent cinema mode state",
            context: ["phase": phase.rawValue]
        )

        stopRuntimeMonitors()
        floatingPanelController.hide()

        if let currentSnapshot = snapshot {
            do {
                try presentationController.restore(from: currentSnapshot)
                if let environmentSnapshot {
                    try environmentPreferencesController.restore(
                        from: environmentSnapshot,
                        preferences: preferencesStore,
                        after: presentationController.transitionDelay(for: .exitEnvironment)
                    )
                }
                presentExitFeedback()
                snapshot = nil
                self.environmentSnapshot = nil
            } catch {
                phase = .failed
                lastError = .presentationRestoreFailed(error.localizedDescription)
                logger.error(
                    module: "presentation",
                    action: "options.restore.failed",
                    message: "Failed to restore presentation options during recovery",
                    error: error,
                    context: ["restoreAttemptCount": "\(currentSnapshot.restoreAttemptCount)"]
                )
                return
            }
        }

        enteredAt = nil
        lastError = nil
        phase = .idle
    }

    private func handlePointerVisibilityChange(_ visibility: PointerVisibilityState) {
        guard phase == .active else {
            return
        }

        floatingPanelController.update(pointerVisibility: visibility)
        logger.debug(
            module: "pointer",
            action: "visibility.change",
            message: "Pointer visibility changed",
            context: [
                "activity": visibility.activity.rawValue,
                "targetOpacity": String(format: "%.2f", visibility.targetOpacity)
            ]
        )
    }

    private func stopRuntimeMonitors() {
        pointerMonitor.stop()
    }

    private func presentEnterFeedback() {
        let copy = CinemaModeCopy(language: preferencesStore.preferredLanguage)
        var items: [String] = [
            copy.feedbackMenuBarHidden,
            copy.feedbackVolumeAdjusted(Int(preferencesStore.preferredVolume.rounded()))
        ]

        if supportsDockAutoHide && preferencesStore.temporarilyAutoHideDock {
            items.append(copy.feedbackDockHidden)
        }

        feedbackPresenter?.present(title: copy.feedbackActiveTitle, items: items)
    }

    private func presentExitFeedback() {
        let copy = CinemaModeCopy(language: preferencesStore.preferredLanguage)
        var items: [String] = [
            copy.feedbackMenuBarRestored,
            copy.feedbackVolumeRestored
        ]

        if supportsDockAutoHide {
            items.append(copy.feedbackDockRestored)
        }

        feedbackPresenter?.present(title: copy.feedbackExitTitle, items: items)
    }

    private func handleEnterFailure(_ error: Error) {
        stopRuntimeMonitors()
        floatingPanelController.hide()

        if let currentSnapshot = snapshot {
            do {
                try presentationController.restore(from: currentSnapshot)
                if let environmentSnapshot {
                    try environmentPreferencesController.restore(
                        from: environmentSnapshot,
                        preferences: preferencesStore,
                        after: presentationController.transitionDelay(for: .exitEnvironment)
                    )
                }
                logger.warn(
                    module: "presentation",
                    action: "options.restore",
                    message: "Presentation options restored after enter failure",
                    context: ["restoreAttemptCount": "\(currentSnapshot.restoreAttemptCount)"]
                )
            } catch {
                logger.error(
                    module: "presentation",
                    action: "options.restore.failed",
                    message: "Failed to restore presentation options after enter failure",
                    error: error,
                    context: ["restoreAttemptCount": "\(currentSnapshot.restoreAttemptCount)"]
                )
            }
        }

        phase = .failed
        enteredAt = nil
        environmentSnapshot = nil

        if let appError = error as? AppError {
            lastError = appError
        } else {
            lastError = .invalidState(error.localizedDescription)
        }

        logger.error(
            module: "cinemaMode",
            action: "enter.failed",
            message: "Failed to enter cinema mode",
            error: error,
            context: ["phase": phase.rawValue]
        )
    }
}
