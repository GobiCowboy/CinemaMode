import Foundation

public enum AppError: Error, Equatable, LocalizedError, Sendable {
    case invalidState(String)
    case presentationCaptureFailed(String)
    case presentationApplyFailed(String)
    case presentationRestoreFailed(String)
    case floatingPanelFailed(String)
    case pointerMonitorFailed(String)

    public var errorDescription: String? {
        switch self {
        case .invalidState(let message),
             .presentationCaptureFailed(let message),
             .presentationApplyFailed(let message),
             .presentationRestoreFailed(let message),
             .floatingPanelFailed(let message),
             .pointerMonitorFailed(let message):
            return message
        }
    }
}

