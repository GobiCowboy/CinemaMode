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
                    .frame(width: 50, height: 50)
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
        }
        .buttonStyle(.plain)
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
