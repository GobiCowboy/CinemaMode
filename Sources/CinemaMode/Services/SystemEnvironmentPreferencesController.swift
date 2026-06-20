import AppKit
import CinemaModeCore
import Foundation

@MainActor
final class SystemEnvironmentPreferencesController: EnvironmentPreferencesControlling {
    private let logger: SystemLogger
    private let edition: AppEdition
    private var pendingEnvironmentWorkItem: DispatchWorkItem?

    init(logger: SystemLogger, edition: AppEdition) {
        self.logger = logger
        self.edition = edition
    }

    func captureSnapshot() throws -> EnvironmentPreferencesSnapshot {
        do {
            let snapshot = EnvironmentPreferencesSnapshot(
                outputVolume: try currentOutputVolume(),
                dockAutoHideEnabled: try currentDockAutoHideEnabled()
            )

            logger.info(
                module: "preferences",
                action: "snapshot.capture",
                message: "Environment preferences snapshot captured",
                context: [
                    "volume": snapshot.outputVolume.map { String(format: "%.2f", $0) } ?? "unsupported",
                    "dockAutoHide": snapshot.dockAutoHideEnabled.map { $0 ? "true" : "false" } ?? "unsupported"
                ]
            )
            return snapshot
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.preferencesCaptureFailed(error.localizedDescription)
        }
    }

    func applyPreferences(from preferences: PreferencesStore, after delay: TimeInterval) throws {
        scheduleEnvironmentUpdate(after: delay) { [weak self] in
            guard let self else { return }
            do {
                try self.setOutputVolume(preferences.preferredVolumeFraction)
                try self.setDockAutoHideEnabledIfNeeded(preferences.temporarilyAutoHideDock)

                self.logger.info(
                    module: "preferences",
                    action: "apply",
                    message: "Environment preferences applied",
                    context: [
                        "volume": "\(Int(preferences.preferredVolume))",
                        "dockAutoHide": preferences.temporarilyAutoHideDock ? "true" : "false",
                        "delayMs": "\(Int(delay * 1000))"
                    ]
                )
            } catch {
                self.logger.error(
                    module: "preferences",
                    action: "apply.failed",
                    message: "Failed to apply environment preferences",
                    error: error,
                    context: ["delayMs": "\(Int(delay * 1000))"]
                )
            }
        }
    }

    func restore(from snapshot: EnvironmentPreferencesSnapshot, preferences: PreferencesStore, after delay: TimeInterval) throws {
        scheduleEnvironmentUpdate(after: delay) { [weak self] in
            guard let self else { return }
            do {
                if preferences.restoreVolumeOnExit, let outputVolume = snapshot.outputVolume {
                    try self.setOutputVolume(outputVolume)
                }
                if let dockAutoHideEnabled = snapshot.dockAutoHideEnabled {
                    try self.restoreDockAutoHideEnabledIfNeeded(dockAutoHideEnabled)
                }

                self.logger.info(
                    module: "preferences",
                    action: "restore",
                    message: "Environment preferences restored",
                    context: [
                        "restoredVolume": "\(preferences.restoreVolumeOnExit)",
                        "restoredDockAutoHide": snapshot.dockAutoHideEnabled.map { $0 ? "true" : "false" } ?? "unsupported",
                        "delayMs": "\(Int(delay * 1000))"
                    ]
                )
            } catch {
                self.logger.error(
                    module: "preferences",
                    action: "restore.failed",
                    message: "Failed to restore environment preferences",
                    error: error,
                    context: ["delayMs": "\(Int(delay * 1000))"]
                )
            }
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

    private func currentDockAutoHideEnabled() throws -> Bool? {
        guard edition.supportsDockAutoHide else {
            return nil
        }

        let output = try runProcess(arguments: ["/usr/bin/defaults", "read", "com.apple.dock", "autohide"])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        switch output.lowercased() {
        case "1", "true":
            return true
        case "0", "false":
            return false
        default:
            return nil
        }
    }

    private func setDockAutoHideEnabledIfNeeded(_ isEnabled: Bool) throws {
        guard edition.supportsDockAutoHide else {
            return
        }
        try setDockAutoHideEnabled(isEnabled)
    }

    private func restoreDockAutoHideEnabledIfNeeded(_ isEnabled: Bool) throws {
        guard edition.supportsDockAutoHide else {
            return
        }
        try setDockAutoHideEnabled(isEnabled)
    }

    private func setDockAutoHideEnabled(_ isEnabled: Bool) throws {
        _ = try runProcess(arguments: ["/usr/bin/defaults", "write", "com.apple.dock", "autohide", "-bool", isEnabled ? "true" : "false"])
        _ = try runProcess(arguments: ["/usr/bin/killall", "Dock"])
    }

    private func scheduleEnvironmentUpdate(after delay: TimeInterval, work: @escaping @MainActor () -> Void) {
        pendingEnvironmentWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            Task { @MainActor in
                work()
            }
        }
        pendingEnvironmentWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func runProcess(arguments: [String]) throws -> String {
        guard let executable = arguments.first else {
            throw AppError.preferencesApplyFailed("Missing executable path")
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = Array(arguments.dropFirst())

        let standardOutput = Pipe()
        let standardError = Pipe()
        process.standardOutput = standardOutput
        process.standardError = standardError

        try process.run()
        process.waitUntilExit()

        let outputData = standardOutput.fileHandleForReading.readDataToEndOfFile()
        let errorData = standardError.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        let errorOutput = String(decoding: errorData, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)

        guard process.terminationStatus == 0 else {
            throw AppError.preferencesApplyFailed(errorOutput.isEmpty ? "Process failed: \(arguments.joined(separator: " "))" : errorOutput)
        }

        return output
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
