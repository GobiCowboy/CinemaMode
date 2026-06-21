import Combine
import Foundation
import CoreGraphics

@MainActor
public final class PreferencesStore: ObservableObject {
    @Published public var preferredVolume: Double {
        didSet { defaults.set(preferredVolume, forKey: Keys.preferredVolume) }
    }

    @Published public var preferredFloatingAnchorRawValue: String {
        didSet {
            defaults.set(preferredFloatingAnchorRawValue, forKey: Keys.preferredFloatingAnchor)
            if preferredFloatingAnchor != .custom {
                clearFloatingPanelOrigin()
            }
        }
    }

    @Published public var restoreVolumeOnExit: Bool {
        didSet { defaults.set(restoreVolumeOnExit, forKey: Keys.restoreVolumeOnExit) }
    }

    @Published public var preferredLanguageRawValue: String {
        didSet { defaults.set(preferredLanguageRawValue, forKey: Keys.preferredLanguage) }
    }

    @Published public var floatingPanelScale: Double {
        didSet { defaults.set(floatingPanelScale, forKey: Keys.floatingPanelScale) }
    }

    @Published public var floatingPanelOriginX: Double? {
        didSet { storeFloatingPanelOriginIfNeeded() }
    }

    @Published public var floatingPanelOriginY: Double? {
        didSet { storeFloatingPanelOriginIfNeeded() }
    }

    @Published public var floatingPanelScreenIdentifier: String? {
        didSet { defaults.set(floatingPanelScreenIdentifier, forKey: Keys.floatingPanelScreenIdentifier) }
    }

    @Published public var temporarilyAutoHideDock: Bool {
        didSet { defaults.set(temporarilyAutoHideDock, forKey: Keys.temporarilyAutoHideDock) }
    }

    private let defaults: UserDefaults
    private var isResettingFloatingPanelOrigin = false
    private var isUpdatingFloatingPanelOrigin = false

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        defaults.register(defaults: [
            Keys.preferredVolume: 65.0,
            Keys.restoreVolumeOnExit: true,
            Keys.preferredLanguage: AppLanguage.system.rawValue,
            Keys.floatingPanelScale: 1.0,
            Keys.preferredFloatingAnchor: FloatingAnchor.topRight.rawValue,
            Keys.temporarilyAutoHideDock: true
        ])

        preferredVolume = defaults.double(forKey: Keys.preferredVolume)
        preferredFloatingAnchorRawValue = defaults.string(forKey: Keys.preferredFloatingAnchor) ?? FloatingAnchor.topRight.rawValue
        restoreVolumeOnExit = defaults.bool(forKey: Keys.restoreVolumeOnExit)
        preferredLanguageRawValue = defaults.string(forKey: Keys.preferredLanguage) ?? AppLanguage.system.rawValue
        floatingPanelScale = defaults.double(forKey: Keys.floatingPanelScale)
        if defaults.object(forKey: Keys.floatingPanelOriginX) != nil,
           defaults.object(forKey: Keys.floatingPanelOriginY) != nil {
            floatingPanelOriginX = defaults.double(forKey: Keys.floatingPanelOriginX)
            floatingPanelOriginY = defaults.double(forKey: Keys.floatingPanelOriginY)
        } else {
            floatingPanelOriginX = nil
            floatingPanelOriginY = nil
        }
        floatingPanelScreenIdentifier = defaults.string(forKey: Keys.floatingPanelScreenIdentifier)
        temporarilyAutoHideDock = defaults.bool(forKey: Keys.temporarilyAutoHideDock)
    }

    public var preferredLanguage: AppLanguage {
        AppLanguage.from(rawValue: preferredLanguageRawValue)
    }

    public var preferredVolumeFraction: Double {
        preferredVolume / 100.0
    }

    public var preferredFloatingAnchor: FloatingAnchor {
        FloatingAnchor(rawValue: preferredFloatingAnchorRawValue) ?? .topRight
    }

    public var floatingPanelOrigin: CGPoint? {
        get {
            guard let floatingPanelOriginX, let floatingPanelOriginY else {
                return nil
            }
            return CGPoint(x: floatingPanelOriginX, y: floatingPanelOriginY)
        }
        set {
            isUpdatingFloatingPanelOrigin = true
            floatingPanelOriginX = newValue.map { Double($0.x) }
            floatingPanelOriginY = newValue.map { Double($0.y) }
            isUpdatingFloatingPanelOrigin = false
            storeFloatingPanelOriginIfNeeded()
        }
    }

    public var floatingPanelScalePercentage: Int {
        Int((floatingPanelScale * 100).rounded())
    }

    private func storeFloatingPanelOriginIfNeeded() {
        guard !isResettingFloatingPanelOrigin, !isUpdatingFloatingPanelOrigin else {
            return
        }

        if let floatingPanelOriginX, let floatingPanelOriginY {
            defaults.set(floatingPanelOriginX, forKey: Keys.floatingPanelOriginX)
            defaults.set(floatingPanelOriginY, forKey: Keys.floatingPanelOriginY)
            defaults.set(floatingPanelScreenIdentifier, forKey: Keys.floatingPanelScreenIdentifier)
        }
    }

    private func clearFloatingPanelOrigin() {
        isResettingFloatingPanelOrigin = true
        floatingPanelOriginX = nil
        floatingPanelOriginY = nil
        floatingPanelScreenIdentifier = nil
        isResettingFloatingPanelOrigin = false
        defaults.removeObject(forKey: Keys.floatingPanelOriginX)
        defaults.removeObject(forKey: Keys.floatingPanelOriginY)
        defaults.removeObject(forKey: Keys.floatingPanelScreenIdentifier)
    }

    private enum Keys {
        static let preferredVolume = "preferences.preferredVolume"
        static let preferredFloatingAnchor = "preferences.preferredFloatingAnchor"
        static let restoreVolumeOnExit = "preferences.restoreVolumeOnExit"
        static let preferredLanguage = "preferences.preferredLanguage"
        static let floatingPanelScale = "preferences.floatingPanelScale"
        static let floatingPanelOriginX = "preferences.floatingPanelOriginX"
        static let floatingPanelOriginY = "preferences.floatingPanelOriginY"
        static let floatingPanelScreenIdentifier = "preferences.floatingPanelScreenIdentifier"
        static let temporarilyAutoHideDock = "preferences.temporarilyAutoHideDock"
    }
}
