import AppKit
import CinemaModeCore
import Foundation

@MainActor
final class SystemEnvironmentPreferencesController: EnvironmentPreferencesControlling {
    private let logger: SystemLogger

    init(logger: SystemLogger) {
        self.logger = logger
    }

    func captureSnapshot() throws -> EnvironmentPreferencesSnapshot {
        do {
            let snapshot = EnvironmentPreferencesSnapshot(
                outputVolume: try currentOutputVolume()
            )

            logger.info(
                module: "preferences",
                action: "snapshot.capture",
                message: "Environment preferences snapshot captured",
                context: [
                    "volume": snapshot.outputVolume.map { String(format: "%.2f", $0) } ?? "unsupported"
                ]
            )
            return snapshot
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.preferencesCaptureFailed(error.localizedDescription)
        }
    }

    func applyPreferences(from preferences: PreferencesStore) throws {
        do {
            try setOutputVolume(preferences.preferredVolumeFraction)

            logger.info(
                module: "preferences",
                action: "apply",
                message: "Environment preferences applied",
                context: [
                    "volume": "\(Int(preferences.preferredVolume))"
                ]
            )
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.preferencesApplyFailed(error.localizedDescription)
        }
    }

    func restore(from snapshot: EnvironmentPreferencesSnapshot, preferences: PreferencesStore) throws {
        do {
            if preferences.restoreVolumeOnExit, let outputVolume = snapshot.outputVolume {
                try setOutputVolume(outputVolume)
            }

            logger.info(
                module: "preferences",
                action: "restore",
                message: "Environment preferences restored",
                context: [
                    "restoredVolume": "\(preferences.restoreVolumeOnExit)"
                ]
            )
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.preferencesRestoreFailed(error.localizedDescription)
        }
    }

    private func currentOutputVolume() throws -> Double? {
        let script = "output volume of (get volume settings)"
        let value = try runAppleScript(script)
        guard let number = Double(value.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return nil
        }
        return max(0.0, min(1.0, number / 100.0))
    }

    private func setOutputVolume(_ value: Double) throws {
        let percent = Int(max(0.0, min(1.0, value)) * 100.0)
        _ = try runAppleScript("set volume output volume \(percent)")
    }

    private func runAppleScript(_ source: String) throws -> String {
        guard let script = NSAppleScript(source: source) else {
            throw AppError.preferencesApplyFailed("Failed to create AppleScript")
        }

        var error: NSDictionary?
        let result = script.executeAndReturnError(&error)
        if let error {
            throw AppError.preferencesApplyFailed(error.description)
        }
        return result.stringValue ?? ""
    }
}
