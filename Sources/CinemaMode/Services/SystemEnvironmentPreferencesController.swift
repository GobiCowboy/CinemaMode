import AppKit
import CinemaModeCore
import CoreGraphics
import Foundation
import IOKit
import IOKit.graphics

@MainActor
final class SystemEnvironmentPreferencesController: EnvironmentPreferencesControlling {
    private let logger: SystemLogger

    init(logger: SystemLogger) {
        self.logger = logger
    }

    func captureSnapshot() throws -> EnvironmentPreferencesSnapshot {
        do {
            let snapshot = EnvironmentPreferencesSnapshot(
                outputVolume: try currentOutputVolume(),
                displayBrightness: try currentDisplayBrightness(),
                doNotDisturbWasEnabled: nil
            )

            logger.info(
                module: "preferences",
                action: "snapshot.capture",
                message: "Environment preferences snapshot captured",
                context: [
                    "brightness": snapshot.displayBrightness.map { String(format: "%.2f", $0) } ?? "unsupported",
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
            try setDisplayBrightness(preferences.preferredBrightnessFraction)

            logger.info(
                module: "preferences",
                action: "apply",
                message: "Environment preferences applied",
                context: [
                    "brightness": "\(Int(preferences.preferredBrightness))",
                    "doNotDisturb": "\(preferences.isDoNotDisturbEnabled)",
                    "escExit": "\(preferences.exitWithEscapeKey)",
                    "volume": "\(Int(preferences.preferredVolume))"
                ]
            )

            if preferences.isDoNotDisturbEnabled {
                logger.warn(
                    module: "preferences",
                    action: "dnd.unsupported",
                    message: "Do Not Disturb preference is stored but not yet applied",
                    context: nil
                )
            }
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

            if preferences.restoreBrightnessOnExit, let displayBrightness = snapshot.displayBrightness {
                try setDisplayBrightness(displayBrightness)
            }

            logger.info(
                module: "preferences",
                action: "restore",
                message: "Environment preferences restored",
                context: [
                    "restoredBrightness": "\(preferences.restoreBrightnessOnExit)",
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

    private func currentDisplayBrightness() throws -> Double? {
        guard let service = mainDisplayService() else {
            return nil
        }
        defer { IOObjectRelease(service) }

        var brightness: Float = 0
        let result = IODisplayGetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, &brightness)
        guard result == kIOReturnSuccess else {
            return nil
        }
        return Double(brightness)
    }

    private func setDisplayBrightness(_ value: Double) throws {
        guard let service = mainDisplayService() else {
            logger.warn(
                module: "preferences",
                action: "brightness.unsupported",
                message: "Built-in display brightness control unavailable",
                context: nil
            )
            return
        }

        defer { IOObjectRelease(service) }

        let clampedValue = Float(max(0.0, min(1.0, value)))
        let result = IODisplaySetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, clampedValue)
        if result != kIOReturnSuccess {
            throw AppError.preferencesApplyFailed("Failed to set built-in display brightness")
        }
    }

    private func mainDisplayService() -> io_service_t? {
        if let service = matchingService(named: "AppleARMBacklight") {
            logger.debug(
                module: "preferences",
                action: "brightness.service.selected",
                message: "Using AppleARMBacklight brightness service",
                context: ["provider": "AppleARMBacklight"]
            )
            return service
        }

        let displayID = CGMainDisplayID()
        let vendorID = CGDisplayVendorNumber(displayID)
        let productID = CGDisplayModelNumber(displayID)
        let serialNumber = CGDisplaySerialNumber(displayID)
        guard let matching = IOServiceMatching("IODisplayConnect") else {
            return nil
        }

        var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == kIOReturnSuccess else {
            return nil
        }
        defer {
            IOObjectRelease(iterator)
        }

        var matchedService: io_service_t?
        while case let service = IOIteratorNext(iterator), service != 0 {
            defer {
                if matchedService != service {
                    IOObjectRelease(service)
                }
            }

            guard let info = IODisplayCreateInfoDictionary(service, 0).takeRetainedValue() as? [String: Any] else {
                continue
            }

            let candidateVendor = info[kDisplayVendorID as String] as? UInt32
            let candidateProduct = info[kDisplayProductID as String] as? UInt32
            let candidateSerial = info[kDisplaySerialNumber as String] as? UInt32

            guard candidateVendor == vendorID, candidateProduct == productID else {
                continue
            }

            if serialNumber != 0, let candidateSerial, candidateSerial != serialNumber {
                continue
            }

            matchedService = service
            break
        }

        if matchedService != nil {
            logger.debug(
                module: "preferences",
                action: "brightness.service.selected",
                message: "Using IODisplayConnect brightness service",
                context: ["provider": "IODisplayConnect"]
            )
        }

        return matchedService
    }

    private func matchingService(named serviceName: String) -> io_service_t? {
        guard let matching = IOServiceMatching(serviceName) else {
            return nil
        }

        let service = IOServiceGetMatchingService(kIOMainPortDefault, matching)
        guard service != 0 else {
            return nil
        }

        return service
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
