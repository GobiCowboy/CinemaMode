import Foundation

public struct EnvironmentPreferencesSnapshot: Equatable, Sendable {
    public var outputVolume: Double?
    public var displayBrightness: Double?
    public var doNotDisturbWasEnabled: Bool?

    public init(
        outputVolume: Double? = nil,
        displayBrightness: Double? = nil,
        doNotDisturbWasEnabled: Bool? = nil
    ) {
        self.outputVolume = outputVolume
        self.displayBrightness = displayBrightness
        self.doNotDisturbWasEnabled = doNotDisturbWasEnabled
    }
}
