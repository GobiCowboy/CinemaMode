import AppKit
import Foundation
import SwiftUI
import CinemaModeCore

struct ExitFloatingView: View {
    @ObservedObject var model: FloatingWindowModel
    let onExit: @Sendable () -> Void
    let onDrag: (CGSize) -> Void
    let onPointerEvent: (String, [String: String]) -> Void

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.38),
                            Color.cyan.opacity(0.12),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 38
                    )
                )
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.45),
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.20, green: 0.22, blue: 0.28).opacity(0.96),
                            Color(red: 0.05, green: 0.06, blue: 0.08).opacity(0.96)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
            Image(systemName: "movieclapper.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color(red: 0.84, green: 0.93, blue: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Image(systemName: "arrow.up.right")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.cyan)
                .offset(x: 14, y: -14)
            FloatingPanelEventCatcher(
                onExit: onExit,
                onDrag: onDrag,
                onPointerEvent: onPointerEvent
            )
            .frame(width: 72, height: 72)
        }
        .frame(width: 72, height: 72)
        .contentShape(Circle())
        .opacity(model.state.opacity)
        .scaleEffect(model.state.isHovered ? 1.06 : 1.0)
        .shadow(color: .black.opacity(model.state.isHovered ? 0.42 : 0.28), radius: model.state.isHovered ? 20 : 14, x: 0, y: 10)
        .animation(.spring(response: 0.22, dampingFraction: 0.78), value: model.state.isHovered)
        .onHover { isHovering in
            model.setHovered(isHovering)
        }
    }
}

private struct FloatingPanelEventCatcher: NSViewRepresentable {
    let onExit: @Sendable () -> Void
    let onDrag: (CGSize) -> Void
    let onPointerEvent: (String, [String: String]) -> Void

    func makeNSView(context: Context) -> FloatingPanelEventView {
        FloatingPanelEventView(
            onExit: onExit,
            onDrag: onDrag,
            onPointerEvent: onPointerEvent
        )
    }

    func updateNSView(_ nsView: FloatingPanelEventView, context: Context) {
        nsView.onExit = onExit
        nsView.onDrag = onDrag
        nsView.onPointerEvent = onPointerEvent
    }
}

private final class FloatingPanelEventView: NSView {
    var onExit: (@Sendable () -> Void)
    var onDrag: (CGSize) -> Void
    var onPointerEvent: (String, [String: String]) -> Void

    private var mouseDownLocation: CGPoint?
    private var lastDragLocation: CGPoint?
    private var didDrag = false

    init(
        onExit: @escaping @Sendable () -> Void,
        onDrag: @escaping (CGSize) -> Void,
        onPointerEvent: @escaping (String, [String: String]) -> Void
    ) {
        self.onExit = onExit
        self.onDrag = onDrag
        self.onPointerEvent = onPointerEvent
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    override func mouseDown(with event: NSEvent) {
        let location = NSEvent.mouseLocation
        mouseDownLocation = location
        lastDragLocation = location
        didDrag = false
        onPointerEvent("pointer.down", [
            "location": pointSummary(location),
            "windowIsKey": "\(window?.isKeyWindow ?? false)",
            "windowIsMain": "\(window?.isMainWindow ?? false)"
        ])
    }

    override func mouseDragged(with event: NSEvent) {
        let location = NSEvent.mouseLocation
        guard let lastDragLocation else {
            self.lastDragLocation = location
            return
        }

        let delta = CGSize(
            width: location.x - lastDragLocation.x,
            height: location.y - lastDragLocation.y
        )
        if let mouseDownLocation {
            let dragDistance = hypot(location.x - mouseDownLocation.x, location.y - mouseDownLocation.y)
            didDrag = dragDistance >= 4
        }

        if abs(delta.width) > 0.5 || abs(delta.height) > 0.5 {
            onDrag(delta)
        }
        self.lastDragLocation = location
    }

    override func mouseUp(with event: NSEvent) {
        defer {
            mouseDownLocation = nil
            lastDragLocation = nil
            didDrag = false
        }

        let location = NSEvent.mouseLocation
        let downLocation = mouseDownLocation ?? location
        let distance = hypot(location.x - downLocation.x, location.y - downLocation.y)
        onPointerEvent("pointer.up", [
            "didDrag": "\(didDrag)",
            "distance": String(format: "%.2f", distance),
            "location": pointSummary(location),
            "windowIsKey": "\(window?.isKeyWindow ?? false)",
            "windowIsMain": "\(window?.isMainWindow ?? false)"
        ])
        if distance < 4 {
            onExit()
        }
    }

    private func pointSummary(_ point: CGPoint) -> String {
        "x:\(Int(point.x)),y:\(Int(point.y))"
    }
}
