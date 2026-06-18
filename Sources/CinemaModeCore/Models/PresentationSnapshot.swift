import Foundation

public struct PresentationSnapshot: Equatable, Sendable {
    public var presentationOptionsRawValue: UInt
    public var systemUIModeRawValue: UInt32
    public var systemUIOptionsRawValue: UInt32
    public var capturedAt: Date
    public var restoreAttemptCount: Int

    public init(
        presentationOptionsRawValue: UInt,
        systemUIModeRawValue: UInt32 = 0,
        systemUIOptionsRawValue: UInt32 = 0,
        capturedAt: Date = Date(),
        restoreAttemptCount: Int = 0
    ) {
        self.presentationOptionsRawValue = presentationOptionsRawValue
        self.systemUIModeRawValue = systemUIModeRawValue
        self.systemUIOptionsRawValue = systemUIOptionsRawValue
        self.capturedAt = capturedAt
        self.restoreAttemptCount = restoreAttemptCount
    }

    public func incrementedRestoreAttempt() -> PresentationSnapshot {
        var copy = self
        copy.restoreAttemptCount += 1
        return copy
    }
}
