import SwiftUI
import CinemaModeCore

struct MainControlView: View {
    @ObservedObject var service: CinemaModeService
    @ObservedObject var preferences: PreferencesStore

    var body: some View {
        let copy = CinemaModeCopy(language: preferences.preferredLanguage)
        VStack(spacing: 20) {
            Button {
                service.enter()
            } label: {
                Label(copy.enterMenuTitle, systemImage: "movieclapper")
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
        let copy = CinemaModeCopy(language: preferences.preferredLanguage)
        switch service.phase {
        case .idle:
            return copy.readyStatus
        case .entering:
            return copy.enteringStatus
        case .active:
            return copy.activeStatus
        case .exiting:
            return copy.exitingStatus
        case .recovering:
            return copy.recoveringStatus
        case .failed:
            return copy.failedStatus
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
