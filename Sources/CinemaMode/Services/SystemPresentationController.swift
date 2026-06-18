import AppKit
import Foundation
import CinemaModeCore

@MainActor
final class SystemPresentationController: PresentationControlling {
    private let logger: SystemLogger

    init(logger: SystemLogger) {
        self.logger = logger
    }

    func captureSnapshot() throws -> PresentationSnapshot {
        let options = NSApp.presentationOptions.rawValue
        let snapshot = PresentationSnapshot(presentationOptionsRawValue: options)
        logger.info(
            module: "presentation",
            action: "snapshot.capture",
            message: "Presentation snapshot captured",
            context: ["optionsRawValue": "\(options)"]
        )
        return snapshot
    }

    func applyCinemaMode(using snapshot: PresentationSnapshot) throws {
        let options: NSApplication.PresentationOptions = [.autoHideMenuBar, .autoHideDock]
        NSApp.presentationOptions = options
        logger.info(
            module: "presentation",
            action: "options.apply",
            message: "Cinema presentation options applied",
            context: ["optionsRawValue": "\(options.rawValue)", "originalOptionsRawValue": "\(snapshot.presentationOptionsRawValue)"]
        )
    }

    func restore(from snapshot: PresentationSnapshot) throws {
        let restored = NSApplication.PresentationOptions(rawValue: snapshot.presentationOptionsRawValue)
        NSApp.presentationOptions = restored
    }
}

