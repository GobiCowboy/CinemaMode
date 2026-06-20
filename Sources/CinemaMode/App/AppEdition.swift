import Foundation

enum AppEdition: String {
    case appStore = "appstore"
    case github = "github"

    static var current: AppEdition {
        let rawValue = Bundle.main.object(forInfoDictionaryKey: "CinemaModeEdition") as? String
        return AppEdition(rawValue: rawValue?.lowercased() ?? "") ?? .appStore
    }

    var supportsDockAutoHide: Bool {
        self == .github
    }
}
