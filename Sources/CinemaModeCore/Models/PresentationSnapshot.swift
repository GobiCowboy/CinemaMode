import Foundation

public struct PresentationSnapshot: Equatable, Sendable {
    public var presentationOptionsRawValue: UInt
    public var capturedAt: Date
    public var restoreAttemptCount: Int

    public init(
        presentationOptionsRawValue: UInt,
        capturedAt: Date = Date(),
        restoreAttemptCount: Int = 0
    ) {
        self.presentationOptionsRawValue = presentationOptionsRawValue
        self.capturedAt = capturedAt
        self.restoreAttemptCount = restoreAttemptCount
    }

    public func incrementedRestoreAttempt() -> PresentationSnapshot {
        var copy = self
        copy.restoreAttemptCount += 1
        return copy
    }
}

