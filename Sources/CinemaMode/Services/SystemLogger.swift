import Foundation
import OSLog
import CinemaModeCore

struct SystemLogger: CinemaModeLogging {
    private let logger: Logger

    init(subsystem: String, category: String) {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    func debug(module: String, action: String, message: String, context: [String : String]?) {
        logger.debug("[\(module, privacy: .public)] \(action, privacy: .public): \(message, privacy: .public) \(Self.format(context))")
    }

    func info(module: String, action: String, message: String, context: [String : String]?) {
        logger.info("[\(module, privacy: .public)] \(action, privacy: .public): \(message, privacy: .public) \(Self.format(context))")
    }

    func warn(module: String, action: String, message: String, context: [String : String]?) {
        logger.warning("[\(module, privacy: .public)] \(action, privacy: .public): \(message, privacy: .public) \(Self.format(context))")
    }

    func error(module: String, action: String, message: String, error: Error?, context: [String : String]?) {
        if let error {
            logger.error("[\(module, privacy: .public)] \(action, privacy: .public): \(message, privacy: .public) \(String(describing: error), privacy: .public) \(Self.format(context))")
        } else {
            logger.error("[\(module, privacy: .public)] \(action, privacy: .public): \(message, privacy: .public) \(Self.format(context))")
        }
    }

    private static func format(_ context: [String: String]?) -> String {
        guard let context, !context.isEmpty else {
            return ""
        }
        return context
            .sorted(by: { $0.key < $1.key })
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
    }
}

