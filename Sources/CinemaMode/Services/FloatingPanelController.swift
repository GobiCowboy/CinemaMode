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
            let contentView = ExitFloatingView(model: model) { [weak self] in
                Task { @MainActor in
                    self?.onExit?()
                }
            }
            let hostingController = NSHostingController(rootView: contentView)
            let panel = FloatingPanel(contentViewController: hostingController)
            panel.level = .statusBar
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle]
            panel.isReleasedWhenClosed = false
            panel.hidesOnDeactivate = false
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = false
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

    private func positionPanel() {
        guard let panel else {
            return
        }

        let visibleFrame = NSScreen.main?.visibleFrame ?? NSScreen.screens.first?.visibleFrame ?? .zero
        let size = CGSize(width: 56, height: 56)
        let margin: CGFloat = 20
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
