import SwiftUI
import CinemaModeCore

@MainActor
final class AppEnvironment: ObservableObject {
    let edition: AppEdition
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
        let edition = AppEdition.current
        let logger = SystemLogger(subsystem: "com.cinemamode.app", category: "core")
        let preferencesStore = PreferencesStore()
        let presentationController = SystemPresentationController(logger: logger)
        let environmentPreferencesController = SystemEnvironmentPreferencesController(logger: logger, edition: edition)
        let floatingPanelController = FloatingPanelController(logger: logger)
        let settingsWindowController = SettingsWindowController(preferences: preferencesStore, edition: edition)
        let pointerMonitor = SystemPointerActivityMonitor(logger: logger)

        self.edition = edition
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

    func openSettings() {
        settingsWindowController.openSettings()
    }
}
