import Foundation

public enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case system
    case chinese
    case english

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .system:
            return "System"
        case .chinese:
            return "中文"
        case .english:
            return "English"
        }
    }

    public var resolved: AppLanguage {
        switch self {
        case .system:
            let code = Locale.current.language.languageCode?.identifier.lowercased()
            return code == "zh" ? .chinese : .english
        case .chinese, .english:
            return self
        }
    }

    public static func from(rawValue: String) -> AppLanguage {
        AppLanguage(rawValue: rawValue) ?? .system
    }
}

public struct CinemaModeCopy {
    public let language: AppLanguage

    public init(language: AppLanguage) {
        self.language = language.resolved
    }

    public var appTitle: String { text(.appTitle) }
    public var settingsTitle: String { text(.settingsTitle) }
    public var settingsMenuTitle: String { text(.settingsMenuTitle) }
    public var enterMenuTitle: String { text(.enterMenuTitle) }
    public var exitMenuTitle: String { text(.exitMenuTitle) }
    public var quitMenuTitle: String { text(.quitMenuTitle) }
    public var readyStatus: String { text(.readyStatus) }
    public var enteringStatus: String { text(.enteringStatus) }
    public var activeStatus: String { text(.activeStatus) }
    public var exitingStatus: String { text(.exitingStatus) }
    public var recoveringStatus: String { text(.recoveringStatus) }
    public var failedStatus: String { text(.failedStatus) }
    public var levelsSection: String { text(.levelsSection) }
    public var languageSection: String { text(.languageSection) }
    public var volumeLabel: String { text(.volumeLabel) }
    public var floatingPanelSection: String { text(.floatingPanelSection) }
    public var floatingPanelSizeLabel: String { text(.floatingPanelSizeLabel) }
    public var githubFeaturesSection: String { text(.githubFeaturesSection) }
    public var dockAutoHideLabel: String { text(.dockAutoHideLabel) }
    public var languageSystem: String { text(.languageSystem) }
    public var languageChinese: String { text(.languageChinese) }
    public var languageEnglish: String { text(.languageEnglish) }
    public var levelsFootnote: String { text(.levelsFootnote) }
    public var languageFootnote: String { text(.languageFootnote) }
    public var floatingPanelFootnote: String { text(.floatingPanelFootnote) }
    public var githubFeaturesFootnote: String { text(.githubFeaturesFootnote) }

    private enum Key {
        case appTitle
        case settingsTitle
        case settingsMenuTitle
        case enterMenuTitle
        case exitMenuTitle
        case quitMenuTitle
        case readyStatus
        case enteringStatus
        case activeStatus
        case exitingStatus
        case recoveringStatus
        case failedStatus
        case levelsSection
        case languageSection
        case volumeLabel
        case floatingPanelSection
        case floatingPanelSizeLabel
        case githubFeaturesSection
        case dockAutoHideLabel
        case languageSystem
        case languageChinese
        case languageEnglish
        case levelsFootnote
        case languageFootnote
        case floatingPanelFootnote
        case githubFeaturesFootnote
    }

    private func text(_ key: Key) -> String {
        switch language {
        case .chinese:
            return chineseText(key)
        case .english:
            return englishText(key)
        case .system:
            return englishText(key)
        }
    }

    private func englishText(_ key: Key) -> String {
        switch key {
        case .appTitle: return "Cinema Mode"
        case .settingsTitle: return "Cinema Mode Settings"
        case .settingsMenuTitle: return "Settings..."
        case .enterMenuTitle: return "Enter Cinema Mode"
        case .exitMenuTitle: return "Exit Cinema Mode"
        case .quitMenuTitle: return "Quit Cinema Mode"
        case .readyStatus: return "Ready"
        case .enteringStatus: return "Entering"
        case .activeStatus: return "Cinema mode active"
        case .exitingStatus: return "Exiting"
        case .recoveringStatus: return "Recovering"
        case .failedStatus: return "Needs recovery"
        case .levelsSection: return "Levels"
        case .languageSection: return "Language"
        case .volumeLabel: return "Volume"
        case .floatingPanelSection: return "Floating Control"
        case .floatingPanelSizeLabel: return "Size"
        case .githubFeaturesSection: return "GitHub Features"
        case .dockAutoHideLabel: return "Temporarily auto-hide Dock"
        case .languageSystem: return "System"
        case .languageChinese: return "Chinese"
        case .languageEnglish: return "English"
        case .levelsFootnote: return "This setting applies to the current system output volume."
        case .languageFootnote: return "System follows the current macOS language."
        case .floatingPanelFootnote: return "The floating control remembers its last position and stays inside the current screen."
        case .githubFeaturesFootnote: return "GitHub edition only. The app restores your original Dock setting when cinema mode exits."
        }
    }

    private func chineseText(_ key: Key) -> String {
        switch key {
        case .appTitle: return "影院模式"
        case .settingsTitle: return "影院模式设置"
        case .settingsMenuTitle: return "设置..."
        case .enterMenuTitle: return "进入观影模式"
        case .exitMenuTitle: return "退出观影模式"
        case .quitMenuTitle: return "退出影院模式"
        case .readyStatus: return "就绪"
        case .enteringStatus: return "进入中"
        case .activeStatus: return "观影模式已开启"
        case .exitingStatus: return "退出中"
        case .recoveringStatus: return "恢复中"
        case .failedStatus: return "需要恢复"
        case .levelsSection: return "强度"
        case .languageSection: return "语言"
        case .volumeLabel: return "音量"
        case .floatingPanelSection: return "浮窗"
        case .floatingPanelSizeLabel: return "大小"
        case .githubFeaturesSection: return "GitHub 版功能"
        case .dockAutoHideLabel: return "观影时临时自动隐藏 Dock"
        case .languageSystem: return "系统"
        case .languageChinese: return "中文"
        case .languageEnglish: return "英文"
        case .levelsFootnote: return "这个设置会影响当前系统输出音量。"
        case .languageFootnote: return "系统会跟随当前 macOS 语言。"
        case .floatingPanelFootnote: return "浮窗会记住上次拖拽位置，并始终限制在当前屏幕可见范围内。"
        case .githubFeaturesFootnote: return "仅 GitHub 分发版提供。退出观影模式后会自动恢复用户原来的 Dock 设置。"
        }
    }
}
