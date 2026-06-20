import Foundation

public struct EnvironmentPreferencesSnapshot: Equatable, Sendable {
    public var outputVolume: Double?
    public var dockAutoHideEnabled: Bool?

    public init(outputVolume: Double? = nil, dockAutoHideEnabled: Bool? = nil) {
        self.outputVolume = outputVolume
        self.dockAutoHideEnabled = dockAutoHideEnabled
    }
}
