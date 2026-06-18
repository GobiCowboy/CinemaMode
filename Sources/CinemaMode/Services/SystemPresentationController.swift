import AppKit
import Carbon.HIToolbox
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
        var systemMode: SystemUIMode = 0
        var systemOptions: SystemUIOptions = 0
        GetSystemUIMode(&systemMode, &systemOptions)
        let snapshot = PresentationSnapshot(
            presentationOptionsRawValue: options,
            systemUIModeRawValue: systemMode,
            systemUIOptionsRawValue: systemOptions
        )
        logger.info(
            module: "presentation",
            action: "snapshot.capture",
            message: "Presentation snapshot captured",
            context: [
                "optionsRawValue": "\(options)",
                "systemUIMode": "\(systemMode)",
                "systemUIOptions": "\(systemOptions)"
            ]
        )
        return snapshot
    }

    func applyCinemaMode(using snapshot: PresentationSnapshot) throws {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        SetSystemUIMode(SystemUIMode(kUIModeAllHidden), 0)
        logger.info(
            module: "presentation",
            action: "options.apply",
            message: "Cinema presentation mode applied",
            context: [
                "originalOptionsRawValue": "\(snapshot.presentationOptionsRawValue)",
                "systemUIMode": "\(kUIModeAllHidden)"
            ]
        )
    }

    func restore(from snapshot: PresentationSnapshot) throws {
        SetSystemUIMode(
            SystemUIMode(snapshot.systemUIModeRawValue),
            SystemUIOptions(snapshot.systemUIOptionsRawValue)
        )
        NSApp.setActivationPolicy(.accessory)
    }
}
