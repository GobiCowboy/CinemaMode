import XCTest
@testable import CinemaModeCore

@MainActor
final class PreferencesStoreTests: XCTestCase {
    func testPreferencesPersistThroughUserDefaults() {
        let suiteName = "CinemaModeCoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = PreferencesStore(defaults: defaults)
        store.isDoNotDisturbEnabled = false
        store.preferredVolume = 42
        store.preferredBrightness = 81
        store.restoreVolumeOnExit = false
        store.restoreBrightnessOnExit = false
        store.exitWithEscapeKey = false

        let reloaded = PreferencesStore(defaults: defaults)

        XCTAssertFalse(reloaded.isDoNotDisturbEnabled)
        XCTAssertEqual(reloaded.preferredVolume, 42)
        XCTAssertEqual(reloaded.preferredBrightness, 81)
        XCTAssertFalse(reloaded.restoreVolumeOnExit)
        XCTAssertFalse(reloaded.restoreBrightnessOnExit)
        XCTAssertFalse(reloaded.exitWithEscapeKey)
    }
}
