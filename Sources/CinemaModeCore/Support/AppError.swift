import Foundation

public enum AppError: Error, Equatable, LocalizedError, Sendable {
    case invalidState(String)
    case presentationCaptureFailed(String)
    case presentationApplyFailed(String)
    case presentationRestoreFailed(String)
    case floatingPanelFailed(String)
    case pointerMonitorFailed(String)
    case preferencesCaptureFailed(String)
    case preferencesApplyFailed(String)
    case preferencesRestoreFailed(String)

    public var errorDescription: String? {
        switch self {
        case .invalidState(let message),
             .presentationCaptureFailed(let message),
             .presentationApplyFailed(let message),
             .presentationRestoreFailed(let message),
             .floatingPanelFailed(let message),
             .pointerMonitorFailed(let message),
             .preferencesCaptureFailed(let message),
             .preferencesApplyFailed(let message),
             .preferencesRestoreFailed(let message):
            return message
        }
    }
}
