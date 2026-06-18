import SwiftUI
import CinemaModeCore

struct MainControlView: View {
    @ObservedObject var service: CinemaModeService

    var body: some View {
        VStack(spacing: 20) {
            Button {
                service.enter()
            } label: {
                Label("Enter Cinema Mode", systemImage: "movieclapper")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                Text(statusText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let error = service.lastError?.errorDescription {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(28)
        .frame(minWidth: 320, minHeight: 220)
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

