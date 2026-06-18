import SwiftUI
import Combine
import CinemaModeCore

@MainActor
final class AppEnvironment: ObservableObject {
    let logger: SystemLogger
    let presentationController: SystemPresentationController
    let floatingPanelController: FloatingPanelController
    let menuBarStatusItemController: MenuBarStatusItemController
    let pointerMonitor: SystemPointerActivityMonitor
    let service: CinemaModeService
    @Published var showMenuBarIcon = true
    private var cancellables = Set<AnyCancellable>()

    init() {
        let logger = SystemLogger(subsystem: "com.cinemamode.app", category: "core")
        let presentationController = SystemPresentationController(logger: logger)
        let floatingPanelController = FloatingPanelController(logger: logger)
        let pointerMonitor = SystemPointerActivityMonitor(logger: logger)
        let service = CinemaModeService(
            presentationController: presentationController,
            floatingPanelController: floatingPanelController,
            pointerMonitor: pointerMonitor,
            logger: logger
        )

        self.logger = logger
        self.presentationController = presentationController
        self.floatingPanelController = floatingPanelController
        self.pointerMonitor = pointerMonitor
        self.service = service
        self.menuBarStatusItemController = MenuBarStatusItemController(service: service, logger: logger)

        service.$phase
            .map { $0 != .active }
            .removeDuplicates()
            .sink { [weak self] shouldShow in
                self?.showMenuBarIcon = shouldShow
                self?.menuBarStatusItemController.setVisible(shouldShow)
            }
            .store(in: &cancellables)

        menuBarStatusItemController.setVisible(true)
    }
}
