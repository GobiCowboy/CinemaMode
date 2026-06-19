import Foundation

@MainActor
public protocol PresentationControlling: Sendable {
    func captureSnapshot() throws -> PresentationSnapshot
    func applyCinemaMode(using snapshot: PresentationSnapshot) throws
    func restore(from snapshot: PresentationSnapshot) throws
}

@MainActor
public protocol FloatingPanelControlling: AnyObject {
    var isVisible: Bool { get }
    func show(state: FloatingWindowState, onExit: @escaping @Sendable () -> Void) throws
    func update(pointerVisibility: PointerVisibilityState)
    func hide()
}

@MainActor
public protocol PointerActivityMonitoring: AnyObject {
    func start(onChange: @escaping @Sendable (PointerVisibilityState) -> Void) throws
    func stop()
}

@MainActor
public protocol EnvironmentPreferencesControlling: Sendable {
    func captureSnapshot() throws -> EnvironmentPreferencesSnapshot
    func applyPreferences(from preferences: PreferencesStore) throws
    func restore(from snapshot: EnvironmentPreferencesSnapshot, preferences: PreferencesStore) throws
}
