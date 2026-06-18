import Foundation

public enum CinemaModePhase: String, Equatable, Sendable {
    case idle
    case entering
    case active
    case exiting
    case recovering
    case failed
}

