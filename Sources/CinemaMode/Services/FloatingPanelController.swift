import AppKit
import SwiftUI
import CinemaModeCore

@MainActor
final class FloatingPanelController: NSObject, FloatingPanelControlling {
    private let logger: SystemLogger
    private var panel: FloatingPanel?
    private var model = FloatingWindowModel()
    private var currentState = FloatingWindowState()
    private var onExit: (@Sendable () -> Void)?

    var isVisible: Bool {
        panel?.isVisible == true
    }

    init(logger: SystemLogger) {
        self.logger = logger
        super.init()
    }

    func show(state: FloatingWindowState, onExit: @escaping @Sendable () -> Void) throws {
        currentState = state.withVisibility(true)
        self.onExit = onExit
        model.state = currentState

        if panel == nil {
            let contentView = ExitFloatingView(
                model: model,
                onExit: { [weak self] in
                    Task { @MainActor in
                        self?.logger.info(
                            module: "floatingPanel",
                            action: "exit.tap",
                            message: "Exit floating panel tapped",
                            context: nil
                        )
                        self?.onExit?()
                    }
                },
                onDrag: { [weak self] delta in
                    Task { @MainActor in
                        self?.move(by: delta)
                    }
                },
                onPointerEvent: { [weak self] action, context in
                    Task { @MainActor in
                        self?.logger.info(
                            module: "floatingPanel",
                            action: action,
                            message: "Exit floating panel pointer event",
                            context: context
                        )
                    }
                }
            )
            let hostingController = NSHostingController(rootView: contentView)
            hostingController.view.wantsLayer = true
            hostingController.view.layer?.cornerRadius = 36
            hostingController.view.layer?.masksToBounds = true
            hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
            let panel = FloatingPanel(
                contentRect: CGRect(x: 0, y: 0, width: 72, height: 72),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            panel.contentViewController = hostingController
            panel.level = .statusBar
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle]
            panel.isReleasedWhenClosed = false
            panel.hidesOnDeactivate = false
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = false
            panel.animationBehavior = .utilityWindow
            panel.isMovable = false
            self.panel = panel
        }

        positionPanel()
        panel?.orderFrontRegardless()

        logger.info(
            module: "floatingPanel",
            action: "show",
            message: "Exit floating panel shown",
            context: ["anchor": state.anchor.rawValue]
        )
    }

    func update(pointerVisibility: PointerVisibilityState) {
        guard panel != nil else {
            return
        }

        if model.state.isHovered {
            currentState = currentState.withHover(true)
        } else {
            currentState = currentState.withOpacity(pointerVisibility.targetOpacity)
        }
        currentState = currentState.withVisibility(true)
        model.state = currentState
    }

    func hide() {
        guard let panel else {
            return
        }

        panel.orderOut(nil)
        self.panel = nil
        model.state = FloatingWindowState()
        currentState = FloatingWindowState()
        onExit = nil

        logger.info(
            module: "floatingPanel",
            action: "close",
            message: "Exit floating panel closed",
            context: nil
        )
    }

    func move(by delta: CGSize) {
        guard let panel else {
            return
        }

        let currentFrame = panel.frame
        let visibleFrame = panel.screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? NSScreen.screens.first?.visibleFrame ?? .zero
        let minX = visibleFrame.minX
        let maxX = visibleFrame.maxX - currentFrame.width
        let minY = visibleFrame.minY
        let maxY = visibleFrame.maxY - currentFrame.height

        let origin = CGPoint(
            x: min(max(currentFrame.origin.x + delta.width, minX), maxX),
            y: min(max(currentFrame.origin.y + delta.height, minY), maxY)
        )

        panel.setFrameOrigin(origin)
    }

    private func positionPanel() {
        guard let panel else {
            return
        }

        let visibleFrame = NSScreen.main?.visibleFrame ?? NSScreen.screens.first?.visibleFrame ?? .zero
        let size = CGSize(width: 72, height: 72)
        let margin: CGFloat = 22
        let origin = CGPoint(
            x: visibleFrame.maxX - size.width - margin,
            y: visibleFrame.minY + margin
        )

        panel.setFrame(CGRect(origin: origin, size: size), display: true)
    }
}

private final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

@MainActor
final class FloatingWindowModel: ObservableObject {
    @Published var state: FloatingWindowState = FloatingWindowState()

    var isHovered: Bool {
        state.isHovered
    }

    func setHovered(_ isHovered: Bool) {
        state = state.withHover(isHovered)
    }
}
