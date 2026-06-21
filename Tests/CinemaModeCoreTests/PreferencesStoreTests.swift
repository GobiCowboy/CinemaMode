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
        store.preferredFloatingAnchorRawValue = FloatingAnchor.bottomLeft.rawValue
        store.temporarilyAutoHideDock = false

        let reloaded = PreferencesStore(defaults: defaults)

        XCTAssertEqual(reloaded.preferredVolume, 42)
        XCTAssertFalse(reloaded.restoreVolumeOnExit)
        XCTAssertEqual(reloaded.preferredFloatingAnchor, .bottomLeft)
        XCTAssertEqual(reloaded.preferredLanguage, .chinese)
        XCTAssertEqual(reloaded.floatingPanelScale, 1.25, accuracy: 0.001)
        XCTAssertNil(reloaded.floatingPanelOrigin)
        XCTAssertNil(reloaded.floatingPanelScreenIdentifier)
        XCTAssertFalse(reloaded.temporarilyAutoHideDock)
    }

    func testCustomFloatingAnchorKeepsDraggedOrigin() {
        let suiteName = "CinemaModeCoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = PreferencesStore(defaults: defaults)
        store.floatingPanelOrigin = CGPoint(x: 120, y: 220)
        store.floatingPanelScreenIdentifier = "screen-a"
        store.preferredFloatingAnchorRawValue = FloatingAnchor.custom.rawValue

        let reloaded = PreferencesStore(defaults: defaults)

        XCTAssertEqual(reloaded.preferredFloatingAnchor, .custom)
        XCTAssertEqual(reloaded.floatingPanelOrigin, CGPoint(x: 120, y: 220))
        XCTAssertEqual(reloaded.floatingPanelScreenIdentifier, "screen-a")
    }
}
