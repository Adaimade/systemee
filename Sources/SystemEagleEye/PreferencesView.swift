import SwiftUI

struct PreferencesView: View {
    @Environment(\.appLanguage) private var appLanguage
    @EnvironmentObject private var metrics: SystemMetricsCollector

    @AppStorage(DisplayPreferences.Keys.barCPU, store: DisplayPreferences.suite) private var barCPU = true
    @AppStorage(DisplayPreferences.Keys.barMemory, store: DisplayPreferences.suite) private var barMemory = true
    @AppStorage(DisplayPreferences.Keys.barDisk, store: DisplayPreferences.suite) private var barDisk = true

    @AppStorage(DisplayPreferences.Keys.cardCPU, store: DisplayPreferences.suite) private var cardCPU = true
    @AppStorage(DisplayPreferences.Keys.cardMemory, store: DisplayPreferences.suite) private var cardMemory = true
    @AppStorage(DisplayPreferences.Keys.cardDisk, store: DisplayPreferences.suite) private var cardDisk = true

    @AppStorage(DisplayPreferences.Keys.pollInterval, store: DisplayPreferences.suite) private var pollInterval = 2.0
    @AppStorage(DisplayPreferences.Keys.uiLanguage, store: DisplayPreferences.suite) private var uiLanguageRaw = AppLanguage.english.storageValue

    var body: some View {
        TabView {
            Form {
                Section {
                    Picker(selection: $uiLanguageRaw) {
                        Text(L10n.string("pref.language.system", language: appLanguage)).tag(AppLanguage.system.storageValue)
                        Text(L10n.string("pref.language.en", language: appLanguage)).tag(AppLanguage.english.storageValue)
                        Text(L10n.string("pref.language.zh_hant", language: appLanguage)).tag(AppLanguage.traditionalChinese.storageValue)
                    } label: {
                        Text(L10n.string("pref.section.language", language: appLanguage))
                    }
                }

                Section {
                    Toggle(isOn: $barCPU) {
                        Text(L10n.string("pref.toggle.bar.cpu", language: appLanguage))
                    }
                    Toggle(isOn: $barMemory) {
                        Text(L10n.string("pref.toggle.bar.memory", language: appLanguage))
                    }
                    Toggle(isOn: $barDisk) {
                        Text(L10n.string("pref.toggle.bar.disk", language: appLanguage))
                    }
                } header: {
                    Text(L10n.string("pref.section.menubar", language: appLanguage))
                }
                Section {
                    Toggle(isOn: $cardCPU) {
                        Text(L10n.string("pref.toggle.card.cpu", language: appLanguage))
                    }
                    Toggle(isOn: $cardMemory) {
                        Text(L10n.string("pref.toggle.card.memory", language: appLanguage))
                    }
                    Toggle(isOn: $cardDisk) {
                        Text(L10n.string("pref.toggle.card.disk", language: appLanguage))
                    }
                } header: {
                    Text(L10n.string("pref.section.card", language: appLanguage))
                }
                Section {
                    Picker(selection: $pollInterval) {
                        Text(L10n.string("pref.poll.1s", language: appLanguage)).tag(1.0)
                        Text(L10n.string("pref.poll.1_5s", language: appLanguage)).tag(1.5)
                        Text(L10n.string("pref.poll.2s", language: appLanguage)).tag(2.0)
                        Text(L10n.string("pref.poll.3s", language: appLanguage)).tag(3.0)
                    } label: {
                        Text(L10n.string("pref.picker.poll", language: appLanguage))
                    }
                    .onChange(of: pollInterval) { _, new in
                        metrics.startPolling(interval: new)
                    }
                } header: {
                    Text(L10n.string("pref.section.update", language: appLanguage))
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label {
                    Text(L10n.string("pref.tab.display", language: appLanguage))
                } icon: {
                    Image(systemName: "slider.horizontal.3")
                }
            }

            Form {
                Section {
                    Text(L10n.string("pref.about.body", language: appLanguage))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label {
                    Text(L10n.string("pref.tab.about", language: appLanguage))
                } icon: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .frame(width: 460, height: 360)
    }
}
