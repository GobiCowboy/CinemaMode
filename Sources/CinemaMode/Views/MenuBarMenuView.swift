import AppKit
import SwiftUI
import CinemaModeCore

struct MenuBarMenuView: View {
    @ObservedObject var service: CinemaModeService

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 10) {
                header
                Divider()
                actionButtons
                Divider()
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Label("Quit Cinema Mode", systemImage: "xmark.circle")
                }
            }
            .padding(.vertical, 2)
        }
        .frame(width: 240)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Cinema Mode")
                .font(.headline)
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var actionButtons: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                service.enter()
            } label: {
                Label("Enter Cinema Mode", systemImage: "play.rectangle")
            }
            .disabled(service.phase == .active || service.phase == .entering)

            Button {
                service.exit()
            } label: {
                Label("Exit Cinema Mode", systemImage: "stop.circle")
            }
            .disabled(service.phase != .active && service.phase != .entering && service.phase != .failed)
        }
    }

    private var statusText: String {
        switch service.phase {
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

    private var statusColor: Color {
        switch service.phase {
        case .idle:
            return .secondary
        case .entering, .exiting, .recovering:
            return .orange
        case .active:
            return .green
        case .failed:
            return .red
        }
    }
}
