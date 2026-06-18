import Foundation

public protocol CinemaModeLogging {
    func debug(module: String, action: String, message: String, context: [String: String]?)
    func info(module: String, action: String, message: String, context: [String: String]?)
    func warn(module: String, action: String, message: String, context: [String: String]?)
    func error(module: String, action: String, message: String, error: Error?, context: [String: String]?)
}

public struct NullCinemaModeLogger: CinemaModeLogging {
    public init() {}

    public func debug(module: String, action: String, message: String, context: [String : String]?) {}
    public func info(module: String, action: String, message: String, context: [String : String]?) {}
    public func warn(module: String, action: String, message: String, context: [String : String]?) {}
    public func error(module: String, action: String, message: String, error: Error?, context: [String : String]?) {}
}
