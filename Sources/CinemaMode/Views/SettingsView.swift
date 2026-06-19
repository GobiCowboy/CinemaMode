import SwiftUI
import CinemaModeCore

struct SettingsView: View {
    @ObservedObject var preferences: PreferencesStore

    var body: some View {
        let copy = CinemaModeCopy(language: preferences.preferredLanguage)
        Form {
            Section {
                Picker("", selection: $preferences.preferredLanguageRawValue) {
                    Text(copy.languageSystem).tag(AppLanguage.system.rawValue)
                    Text(copy.languageChinese).tag(AppLanguage.chinese.rawValue)
                    Text(copy.languageEnglish).tag(AppLanguage.english.rawValue)
                }
                .pickerStyle(.segmented)
            } header: {
                Text(copy.languageSection)
            } footer: {
                Text(copy.languageFootnote)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(copy.volumeLabel, systemImage: "speaker.wave.2.fill")
                        Spacer()
                        Text("\(Int(preferences.preferredVolume))%")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $preferences.preferredVolume, in: 0...100, step: 1)
                }
            } header: {
                Text(copy.levelsSection)
            } footer: {
                Text(copy.levelsFootnote)
            }

            Section {
                LabeledContent(copy.exitCornerLabel) {
                    Text(copy.bottomRightCorner)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text(copy.placementSection)
            } footer: {
                Text(copy.placementFootnote)
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(minWidth: 460, minHeight: 420)
    }
}
