import Foundation

public enum PointerActivity: String, Equatable, Sendable {
    case idle
    case moving
    case hovering

    public var targetOpacity: Double {
        switch self {
        case .idle:
            return 0.05
        case .moving:
            return 0.70
        case .hovering:
            return 1.00
        }
    }
}

public struct PointerVisibilityState: Equatable, Sendable {
    public var activity: PointerActivity
    public var targetOpacity: Double
    public var lastMovedAt: Date?

    public init(activity: PointerActivity, targetOpacity: Double? = nil, lastMovedAt: Date? = nil) {
        self.activity = activity
        self.targetOpacity = targetOpacity ?? activity.targetOpacity
        self.lastMovedAt = lastMovedAt
    }

    public static let idle = PointerVisibilityState(activity: .idle)
    public static let moving = PointerVisibilityState(activity: .moving)
    public static let hovering = PointerVisibilityState(activity: .hovering)
}

