import SwiftUI
import CinemaModeCore

@MainActor
final class AppEnvironment: ObservableObject {
    let logger: SystemLogger
    let presentationController: SystemPresentationController
    let floatingPanelController: FloatingPanelController
    let pointerMonitor: SystemPointerActivityMonitor
    let service: CinemaModeService

    init() {
        let logger = SystemLogger(subsystem: "com.cinemamode.app", category: "core")
        let presentationController = SystemPresentationController(logger: logger)
        let floatingPanelController = FloatingPanelController(logger: logger)
        let pointerMonitor = SystemPointerActivityMonitor(logger: logger)

        self.logger = logger
        self.presentationController = presentationController
        self.floatingPanelController = floatingPanelController
        self.pointerMonitor = pointerMonitor
        self.service = CinemaModeService(
            presentationController: presentationController,
            floatingPanelController: floatingPanelController,
            pointerMonitor: pointerMonitor,
            logger: logger
        )
    }
}
