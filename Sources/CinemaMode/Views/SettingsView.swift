import SwiftUI
import CinemaModeCore

struct SettingsView: View {
    @ObservedObject var preferences: PreferencesStore

    var body: some View {
        let copy = CinemaModeCopy(language: preferences.preferredLanguage)
        Form {
            Section {
                Toggle(copy.doNotDisturbToggle, isOn: $preferences.isDoNotDisturbEnabled)
                Toggle(copy.restoreVolumeToggle, isOn: $preferences.restoreVolumeOnExit)
                Toggle(copy.restoreBrightnessToggle, isOn: $preferences.restoreBrightnessOnExit)
                Toggle(copy.allowEscToggle, isOn: $preferences.exitWithEscapeKey)
            } header: {
                Text(copy.behaviorSection)
            } footer: {
                Text(copy.behaviorFootnote)
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

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(copy.brightnessLabel, systemImage: "sun.max.fill")
                        Spacer()
                        Text("\(Int(preferences.preferredBrightness))%")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $preferences.preferredBrightness, in: 0...100, step: 1)
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
        }
        .formStyle(.grouped)
        .padding()
        .frame(minWidth: 460, minHeight: 420)
    }
}
