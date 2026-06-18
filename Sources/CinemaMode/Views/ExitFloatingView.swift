import SwiftUI
import CinemaModeCore

struct ExitFloatingView: View {
    @ObservedObject var model: FloatingWindowModel
    let onExit: @Sendable () -> Void
    let onDrag: (CGSize) -> Void
    @State private var lastTranslation: CGSize = .zero

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
        }
        .frame(width: 72, height: 72)
        .contentShape(Circle())
        .opacity(model.state.opacity)
        .scaleEffect(model.state.isHovered ? 1.06 : 1.0)
        .shadow(color: .black.opacity(model.state.isHovered ? 0.42 : 0.28), radius: model.state.isHovered ? 20 : 14, x: 0, y: 10)
        .animation(.spring(response: 0.22, dampingFraction: 0.78), value: model.state.isHovered)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let delta = CGSize(
                        width: value.translation.width - lastTranslation.width,
                        height: value.translation.height - lastTranslation.height
                    )
                    if abs(delta.width) > 0.5 || abs(delta.height) > 0.5 {
                        onDrag(delta)
                    }
                    lastTranslation = value.translation
                }
                .onEnded { value in
                    let distance = hypot(value.translation.width, value.translation.height)
                    if distance < 4 {
                        onExit()
                    }
                    lastTranslation = .zero
                }
        )
        .onHover { isHovering in
            model.setHovered(isHovering)
        }
    }
}
