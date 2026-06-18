import SwiftUI
import CinemaModeCore

struct ExitFloatingView: View {
    @ObservedObject var model: FloatingWindowModel
    let onExit: @Sendable () -> Void

    var body: some View {
        Button(action: onExit) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                Circle()
                    .strokeBorder(.white.opacity(0.18), lineWidth: 1)
                Text("🎬")
                    .font(.system(size: 18))
            }
        }
        .buttonStyle(.plain)
        .frame(width: 56, height: 56)
        .contentShape(Circle())
        .opacity(model.state.opacity)
        .onHover { isHovering in
            model.setHovered(isHovering)
        }
    }
}

