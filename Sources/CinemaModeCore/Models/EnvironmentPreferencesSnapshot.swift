import Foundation

public struct EnvironmentPreferencesSnapshot: Equatable, Sendable {
    public var outputVolume: Double?

    public init(outputVolume: Double? = nil) {
        self.outputVolume = outputVolume
    }
}
