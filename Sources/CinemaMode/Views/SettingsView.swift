import SwiftUI
import CinemaModeCore

struct SettingsView: View {
    @ObservedObject var preferences: PreferencesStore
    let edition: AppEdition

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
                        Label(copy.floatingPanelSizeLabel, systemImage: "capsule.lefthalf.filled")
                        Spacer()
                        Text("\(preferences.floatingPanelScalePercentage)%")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $preferences.floatingPanelScale, in: 0.75...1.5, step: 0.05)
                }
            } header: {
                Text(copy.floatingPanelSection)
            } footer: {
                Text(copy.floatingPanelFootnote)
            }

            if edition.supportsDockAutoHide {
                Section {
                    Toggle(isOn: $preferences.temporarilyAutoHideDock) {
                        Label(copy.dockAutoHideLabel, systemImage: "dock.rectangle")
                    }
                } header: {
                    Text(copy.githubFeaturesSection)
                } footer: {
                    Text(copy.githubFeaturesFootnote)
                }
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

        }
        .formStyle(.grouped)
        .padding()
        .frame(minWidth: 460, minHeight: 320)
    }
}
