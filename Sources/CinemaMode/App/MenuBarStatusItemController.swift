import AppKit
import SwiftUI
import CinemaModeCore

@MainActor
final class MenuBarStatusItemController: NSObject {
    private let service: CinemaModeService
    private let logger: SystemLogger
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?

    init(service: CinemaModeService, logger: SystemLogger) {
        self.service = service
        self.logger = logger
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
        button.imagePosition = .imageOnly
        button.image?.isTemplate = true
        button.imageScaling = .scaleProportionallyDown
        button.target = self
        button.action = #selector(togglePopover(_:))
        button.sendAction(on: [.leftMouseUp])
        button.toolTip = "Cinema Mode"

        self.statusItem = statusItem
        logger.info(
            module: "menuBar",
            action: "statusItem.show",
            message: "Menu bar status item shown",
            context: nil
        )
    }

    private func removeStatusItem() {
        popover?.close()
        popover = nil

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

    @objc
    private func togglePopover(_ sender: Any?) {
        guard let button = statusItem?.button else {
            return
        }

        if let popover, popover.isShown {
            popover.performClose(sender)
            return
        }

        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 240, height: 180)
        popover.contentViewController = NSHostingController(
            rootView: MenuBarMenuView(service: service)
                .frame(width: 240)
        )
        self.popover = popover

        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        NSApp.activate(ignoringOtherApps: true)
    }
}
