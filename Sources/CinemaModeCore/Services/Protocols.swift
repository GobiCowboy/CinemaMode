import Foundation

@MainActor
public protocol PresentationControlling: Sendable {
    func captureSnapshot() throws -> PresentationSnapshot
    func applyCinemaMode(using snapshot: PresentationSnapshot) throws
    func restore(from snapshot: PresentationSnapshot) throws
    func transitionDelay(for stage: PresentationTransitionStage) -> TimeInterval
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
    func applyPreferences(from preferences: PreferencesStore, after delay: TimeInterval) throws
    func restore(from snapshot: EnvironmentPreferencesSnapshot, preferences: PreferencesStore, after delay: TimeInterval) throws
}

public enum PresentationTransitionStage: Sendable {
    case enterEnvironment
    case exitEnvironment
}
