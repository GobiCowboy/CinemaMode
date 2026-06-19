import Combine
import Foundation

@MainActor
public final class PreferencesStore: ObservableObject {
    @Published public var isDoNotDisturbEnabled: Bool {
        didSet { defaults.set(isDoNotDisturbEnabled, forKey: Keys.isDoNotDisturbEnabled) }
    }

    @Published public var preferredVolume: Double {
        didSet { defaults.set(preferredVolume, forKey: Keys.preferredVolume) }
    }

    @Published public var preferredBrightness: Double {
        didSet { defaults.set(preferredBrightness, forKey: Keys.preferredBrightness) }
    }

    @Published public var restoreVolumeOnExit: Bool {
        didSet { defaults.set(restoreVolumeOnExit, forKey: Keys.restoreVolumeOnExit) }
    }

    @Published public var restoreBrightnessOnExit: Bool {
        didSet { defaults.set(restoreBrightnessOnExit, forKey: Keys.restoreBrightnessOnExit) }
    }

    @Published public var exitWithEscapeKey: Bool {
        didSet { defaults.set(exitWithEscapeKey, forKey: Keys.exitWithEscapeKey) }
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
            Keys.isDoNotDisturbEnabled: true,
            Keys.preferredVolume: 65.0,
            Keys.preferredBrightness: 75.0,
            Keys.restoreVolumeOnExit: true,
            Keys.restoreBrightnessOnExit: true,
            Keys.exitWithEscapeKey: true,
            Keys.preferredLanguage: AppLanguage.system.rawValue,
            Keys.preferredAnchor: FloatingAnchor.bottomRight.rawValue
        ])

        isDoNotDisturbEnabled = defaults.bool(forKey: Keys.isDoNotDisturbEnabled)
        preferredVolume = defaults.double(forKey: Keys.preferredVolume)
        preferredBrightness = defaults.double(forKey: Keys.preferredBrightness)
        restoreVolumeOnExit = defaults.bool(forKey: Keys.restoreVolumeOnExit)
        restoreBrightnessOnExit = defaults.bool(forKey: Keys.restoreBrightnessOnExit)
        exitWithEscapeKey = defaults.bool(forKey: Keys.exitWithEscapeKey)
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

    public var preferredBrightnessFraction: Double {
        preferredBrightness / 100.0
    }

    private enum Keys {
        static let isDoNotDisturbEnabled = "preferences.isDoNotDisturbEnabled"
        static let preferredVolume = "preferences.preferredVolume"
        static let preferredBrightness = "preferences.preferredBrightness"
        static let restoreVolumeOnExit = "preferences.restoreVolumeOnExit"
        static let restoreBrightnessOnExit = "preferences.restoreBrightnessOnExit"
        static let exitWithEscapeKey = "preferences.exitWithEscapeKey"
        static let preferredLanguage = "preferences.preferredLanguage"
        static let preferredAnchor = "preferences.preferredAnchor"
    }
}
