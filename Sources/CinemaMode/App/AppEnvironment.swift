import SwiftUI
import CinemaModeCore

@MainActor
final class AppEnvironment: ObservableObject {
    let logger: SystemLogger
    let presentationController: SystemPresentationController
    let environmentPreferencesController: SystemEnvironmentPreferencesController
    let floatingPanelController: FloatingPanelController
    let preferencesStore: PreferencesStore
    let settingsWindowController: SettingsWindowController
    let menuBarStatusItemController: MenuBarStatusItemController
    let pointerMonitor: SystemPointerActivityMonitor
    let service: CinemaModeService

    init() {
        let logger = SystemLogger(subsystem: "com.cinemamode.app", category: "core")
        let presentationController = SystemPresentationController(logger: logger)
        let environmentPreferencesController = SystemEnvironmentPreferencesController(logger: logger)
        let floatingPanelController = FloatingPanelController(logger: logger)
        let preferencesStore = PreferencesStore()
        let settingsWindowController = SettingsWindowController(preferences: preferencesStore)
        let pointerMonitor = SystemPointerActivityMonitor(logger: logger)

        self.logger = logger
        self.presentationController = presentationController
        self.environmentPreferencesController = environmentPreferencesController
        self.floatingPanelController = floatingPanelController
        self.preferencesStore = preferencesStore
        self.settingsWindowController = settingsWindowController
        self.pointerMonitor = pointerMonitor
        self.service = CinemaModeService(
            presentationController: presentationController,
            environmentPreferencesController: environmentPreferencesController,
            floatingPanelController: floatingPanelController,
            pointerMonitor: pointerMonitor,
            preferencesStore: preferencesStore,
            logger: logger
        )
        self.menuBarStatusItemController = MenuBarStatusItemController(
            service: service,
            logger: logger,
            settingsWindowController: settingsWindowController,
            preferencesStore: preferencesStore
        )
        self.menuBarStatusItemController.setVisible(true)
    }
}
