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
        store.floatingPanelScale = 1.25
        store.floatingPanelOrigin = CGPoint(x: 320, y: 480)
        store.floatingPanelScreenIdentifier = "screen-a"
        store.temporarilyAutoHideDock = false

        let reloaded = PreferencesStore(defaults: defaults)

        XCTAssertEqual(reloaded.preferredVolume, 42)
        XCTAssertFalse(reloaded.restoreVolumeOnExit)
        XCTAssertEqual(reloaded.preferredLanguage, .chinese)
        XCTAssertEqual(reloaded.floatingPanelScale, 1.25, accuracy: 0.001)
        XCTAssertEqual(reloaded.floatingPanelOrigin, CGPoint(x: 320, y: 480))
        XCTAssertEqual(reloaded.floatingPanelScreenIdentifier, "screen-a")
        XCTAssertFalse(reloaded.temporarilyAutoHideDock)
    }
}
