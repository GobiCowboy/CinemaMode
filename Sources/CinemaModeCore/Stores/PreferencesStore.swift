import Combine
import Foundation

@MainActor
public final class PreferencesStore: ObservableObject {
    @Published public var preferredVolume: Double {
        didSet { defaults.set(preferredVolume, forKey: Keys.preferredVolume) }
    }

    @Published public var restoreVolumeOnExit: Bool {
        didSet { defaults.set(restoreVolumeOnExit, forKey: Keys.restoreVolumeOnExit) }
    }

    @Published public var preferredLanguageRawValue: String {
        didSet { defaults.set(preferredLanguageRawValue, forKey: Keys.preferredLanguage) }
    }

    @Published public var preferredAnchorRawValue: String {
        didSet { defaults.set(preferredAnchorRawValue, forKey: Keys.preferredAnchor) }
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        defaults.register(defaults: [
            Keys.preferredVolume: 65.0,
            Keys.restoreVolumeOnExit: true,
            Keys.preferredLanguage: AppLanguage.system.rawValue,
            Keys.preferredAnchor: FloatingAnchor.bottomRight.rawValue
        ])

        preferredVolume = defaults.double(forKey: Keys.preferredVolume)
        restoreVolumeOnExit = defaults.bool(forKey: Keys.restoreVolumeOnExit)
        preferredLanguageRawValue = defaults.string(forKey: Keys.preferredLanguage) ?? AppLanguage.system.rawValue
        preferredAnchorRawValue = defaults.string(forKey: Keys.preferredAnchor) ?? FloatingAnchor.bottomRight.rawValue
    }

    public var preferredLanguage: AppLanguage {
        AppLanguage.from(rawValue: preferredLanguageRawValue)
    }

    public var preferredAnchor: FloatingAnchor {
        FloatingAnchor(rawValue: preferredAnchorRawValue) ?? .bottomRight
    }

    public var preferredVolumeFraction: Double {
        preferredVolume / 100.0
    }

    private enum Keys {
        static let preferredVolume = "preferences.preferredVolume"
        static let restoreVolumeOnExit = "preferences.restoreVolumeOnExit"
        static let preferredLanguage = "preferences.preferredLanguage"
        static let preferredAnchor = "preferences.preferredAnchor"
    }
}
