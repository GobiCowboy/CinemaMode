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
        store.preferredVolume = 42
        store.restoreVolumeOnExit = false
        store.preferredLanguageRawValue = AppLanguage.chinese.rawValue

        let reloaded = PreferencesStore(defaults: defaults)

        XCTAssertEqual(reloaded.preferredVolume, 42)
        XCTAssertFalse(reloaded.restoreVolumeOnExit)
        XCTAssertEqual(reloaded.preferredLanguage, .chinese)
    }
}
