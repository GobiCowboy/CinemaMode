import SwiftUI
import CinemaModeCore

struct SettingsView: View {
    @ObservedObject var preferences: PreferencesStore

    var body: some View {
        Form {
            Section {
                Toggle("Enable Do Not Disturb", isOn: $preferences.isDoNotDisturbEnabled)
                Toggle("Restore volume on exit", isOn: $preferences.restoreVolumeOnExit)
                Toggle("Restore brightness on exit", isOn: $preferences.restoreBrightnessOnExit)
                Toggle("Allow Esc to exit", isOn: $preferences.exitWithEscapeKey)
            } header: {
                Text("Behavior")
            } footer: {
                Text("These choices apply when Cinema Mode starts and ends.")
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Volume", systemImage: "speaker.wave.2.fill")
                        Spacer()
                        Text("\(Int(preferences.preferredVolume))%")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $preferences.preferredVolume, in: 0...100, step: 1)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("Brightness", systemImage: "sun.max.fill")
                        Spacer()
                        Text("\(Int(preferences.preferredBrightness))%")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $preferences.preferredBrightness, in: 0...100, step: 1)
                }
            } header: {
                Text("Levels")
            } footer: {
                Text("Brightness currently targets the built-in display only.")
            }

            Section {
                LabeledContent("Exit corner") {
                    Text("Bottom-right")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Placement")
            } footer: {
                Text("The app currently keeps the control anchored in the bottom-right corner.")
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(minWidth: 460, minHeight: 420)
    }
}
