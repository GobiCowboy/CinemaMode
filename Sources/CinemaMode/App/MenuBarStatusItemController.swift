import AppKit
import Combine
import CinemaModeCore

@MainActor
final class MenuBarStatusItemController: NSObject, NSMenuDelegate {
    private let service: CinemaModeService
    private let logger: SystemLogger
    private let settingsWindowController: SettingsWindowController
    private var statusItem: NSStatusItem?
    private var statusMenu: NSMenu?
    private var phaseObservation: AnyCancellable?
    private weak var statusLabelItem: NSMenuItem?
    private weak var enterItem: NSMenuItem?
    private weak var exitItem: NSMenuItem?

    init(service: CinemaModeService, logger: SystemLogger, settingsWindowController: SettingsWindowController) {
        self.service = service
        self.logger = logger
        self.settingsWindowController = settingsWindowController
        super.init()
    }

    func setVisible(_ isVisible: Bool) {
        if isVisible {
            installStatusItemIfNeeded()
        } else {
            removeStatusItem()
        }
    }

    private func installStatusItemIfNeeded() {
        guard statusItem == nil else {
            return
        }

        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = statusItem.button else {
            return
        }

        button.image = NSImage(
            systemSymbolName: "movieclapper.fill",
            accessibilityDescription: "Cinema Mode"
        )
        button.image?.size = NSSize(width: 13, height: 13)
        button.image?.isTemplate = true
        button.toolTip = "Cinema Mode"

        let menu = NSMenu()
        menu.delegate = self

        let titleItem = NSMenuItem(title: "Cinema Mode", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)

        let statusItemLabel = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        statusItemLabel.isEnabled = false
        menu.addItem(statusItemLabel)
        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(handleSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let enterItem = NSMenuItem(title: "Enter Cinema Mode", action: #selector(handleEnterCinemaMode), keyEquivalent: "")
        enterItem.target = self
        menu.addItem(enterItem)

        let exitItem = NSMenuItem(title: "Exit Cinema Mode", action: #selector(handleExitCinemaMode), keyEquivalent: "")
        exitItem.target = self
        menu.addItem(exitItem)
        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Cinema Mode", action: #selector(handleQuit), keyEquivalent: "")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu

        self.statusItem = statusItem
        self.statusMenu = menu
        self.statusLabelItem = statusItemLabel
        self.enterItem = enterItem
        self.exitItem = exitItem
        phaseObservation = service.$phase.sink { [weak self] phase in
            Task { @MainActor in
                self?.refreshMenuState(for: phase)
            }
        }
        refreshMenuState(for: service.phase)

        logger.info(
            module: "menuBar",
            action: "statusItem.show",
            message: "Menu bar status item shown",
            context: nil
        )
    }

    private func removeStatusItem() {
        phaseObservation = nil
        statusMenu = nil
        statusLabelItem = nil
        enterItem = nil
        exitItem = nil

        if let statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
            logger.info(
                module: "menuBar",
                action: "statusItem.hide",
                message: "Menu bar status item hidden",
                context: nil
            )
        }
    }

    func menuWillOpen(_ menu: NSMenu) {
        refreshMenuState(for: service.phase)
    }

    @objc
    private func handleEnterCinemaMode() {
        logger.info(
            module: "menuBar",
            action: "enter.tap",
            message: "Enter cinema mode requested from status menu",
            context: ["phase": service.phase.rawValue]
        )
        statusMenu?.cancelTracking()
        DispatchQueue.main.async { [weak self] in
            self?.service.enter()
        }
    }

    @objc
    private func handleExitCinemaMode() {
        logger.info(
            module: "menuBar",
            action: "exit.tap",
            message: "Exit cinema mode requested from status menu",
            context: ["phase": service.phase.rawValue]
        )
        statusMenu?.cancelTracking()
        DispatchQueue.main.async { [weak self] in
            self?.service.exit()
        }
    }

    @objc
    private func handleQuit() {
        NSApplication.shared.terminate(nil)
    }

    @objc
    private func handleSettings() {
        logger.info(
            module: "menuBar",
            action: "settings.tap",
            message: "Settings requested from status menu",
            context: ["phase": service.phase.rawValue]
        )
        statusMenu?.cancelTracking()
        DispatchQueue.main.async { [weak self] in
            self?.settingsWindowController.show()
        }
    }

    private func refreshMenuState(for phase: CinemaModePhase) {
        statusLabelItem?.title = statusText(for: phase)
        enterItem?.isEnabled = phase == .idle
        exitItem?.isEnabled = phase == .active || phase == .entering || phase == .failed
    }

    private func statusText(for phase: CinemaModePhase) -> String {
        switch phase {
        case .idle:
            return "Ready"
        case .entering:
            return "Entering"
        case .active:
            return "Cinema mode active"
        case .exiting:
            return "Exiting"
        case .recovering:
            return "Recovering"
        case .failed:
            return "Needs recovery"
        }
    }
}
