import XCTest
@testable import CinemaModeCore

@MainActor
final class CinemaModeServiceTests: XCTestCase {
    func testEnterHappyPathTransitionsToActive() {
        let presentation = PresentationControllerSpy()
        let panel = FloatingPanelControllerSpy()
        let monitor = PointerMonitorSpy()
        let logger = LoggerSpy()
        let service = CinemaModeService(
            presentationController: presentation,
            floatingPanelController: panel,
            pointerMonitor: monitor,
            logger: logger
        )

        service.enter()

        XCTAssertEqual(service.phase, .active)
        XCTAssertEqual(presentation.captureCount, 1)
        XCTAssertEqual(presentation.applyCount, 1)
        XCTAssertEqual(panel.showCount, 1)
        XCTAssertEqual(monitor.startCount, 1)
        XCTAssertEqual(logger.infoActions, ["cinemaMode:enter.start", "cinemaMode:enter.success"])
    }

    func testEnterWhileActiveIsIgnored() {
        let presentation = PresentationControllerSpy()
        let panel = FloatingPanelControllerSpy()
        let monitor = PointerMonitorSpy()
        let logger = LoggerSpy()
        let service = CinemaModeService(
            presentationController: presentation,
            floatingPanelController: panel,
            pointerMonitor: monitor,
            logger: logger
        )

        service.enter()
        service.enter()

        XCTAssertEqual(service.phase, .active)
        XCTAssertEqual(panel.showCount, 1)
        XCTAssertEqual(monitor.startCount, 1)
        XCTAssertTrue(logger.warnActions.contains("cinemaMode:enter.ignored"))
    }

    func testExitRestoresAndStopsMonitoring() {
        let presentation = PresentationControllerSpy()
        let panel = FloatingPanelControllerSpy()
        let monitor = PointerMonitorSpy()
        let logger = LoggerSpy()
        let service = CinemaModeService(
            presentationController: presentation,
            floatingPanelController: panel,
            pointerMonitor: monitor,
            logger: logger
        )

        service.enter()
        service.exit()

        XCTAssertEqual(service.phase, .idle)
        XCTAssertEqual(presentation.restoreCount, 1)
        XCTAssertEqual(panel.hideCount, 1)
        XCTAssertEqual(monitor.stopCount, 1)
        XCTAssertNil(service.lastError)
    }

    func testEnterFailureRestoresPartialStateAndMarksFailed() {
        let presentation = PresentationControllerSpy()
        let panel = FloatingPanelControllerSpy()
        panel.showError = AppError.floatingPanelFailed("panel failed")
        let monitor = PointerMonitorSpy()
        let logger = LoggerSpy()
        let service = CinemaModeService(
            presentationController: presentation,
            floatingPanelController: panel,
            pointerMonitor: monitor,
            logger: logger
        )

        service.enter()

        XCTAssertEqual(service.phase, .failed)
        XCTAssertEqual(presentation.restoreCount, 1)
        XCTAssertEqual(panel.hideCount, 1)
        XCTAssertEqual(monitor.startCount, 0)
        XCTAssertEqual(service.lastError, .floatingPanelFailed("panel failed"))
        XCTAssertTrue(logger.errorActions.contains("cinemaMode:enter.failed"))
    }
}

@MainActor
final class PresentationControllerSpy: PresentationControlling {
    var captureCount = 0
    var applyCount = 0
    var restoreCount = 0
    var snapshot = PresentationSnapshot(presentationOptionsRawValue: 7)

    func captureSnapshot() throws -> PresentationSnapshot {
        captureCount += 1
        return snapshot
    }

    func applyCinemaMode(using snapshot: PresentationSnapshot) throws {
        applyCount += 1
        self.snapshot = snapshot
    }

    func restore(from snapshot: PresentationSnapshot) throws {
        restoreCount += 1
        self.snapshot = snapshot
    }
}

@MainActor
final class FloatingPanelControllerSpy: FloatingPanelControlling {
    var isVisible = false
    var showCount = 0
    var hideCount = 0
    var updateStates: [PointerVisibilityState] = []
    var showError: AppError?

    func show(state: FloatingWindowState, onExit: @escaping @Sendable () -> Void) throws {
        if let showError {
            throw showError
        }
        showCount += 1
        isVisible = true
    }

    func update(pointerVisibility: PointerVisibilityState) {
        updateStates.append(pointerVisibility)
    }

    func hide() {
        hideCount += 1
        isVisible = false
    }
}

@MainActor
final class PointerMonitorSpy: PointerActivityMonitoring {
    var startCount = 0
    var stopCount = 0
    var onChange: ((PointerVisibilityState) -> Void)?

    func start(onChange: @escaping @Sendable (PointerVisibilityState) -> Void) throws {
        startCount += 1
        self.onChange = onChange
    }

    func stop() {
        stopCount += 1
    }
}

final class LoggerSpy: CinemaModeLogging {
    var infoActions: [String] = []
    var warnActions: [String] = []
    var errorActions: [String] = []

    func debug(module: String, action: String, message: String, context: [String : String]?) {}

    func info(module: String, action: String, message: String, context: [String : String]?) {
        infoActions.append("\(module):\(action)")
    }

    func warn(module: String, action: String, message: String, context: [String : String]?) {
        warnActions.append("\(module):\(action)")
    }

    func error(module: String, action: String, message: String, error: Error?, context: [String : String]?) {
        errorActions.append("\(module):\(action)")
    }
}
