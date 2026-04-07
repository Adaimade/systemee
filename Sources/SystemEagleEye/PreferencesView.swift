import SwiftUI

struct PreferencesView: View {
    @Environment(\.locale) private var locale
    @EnvironmentObject private var metrics: SystemMetricsCollector

    @AppStorage(DisplayPreferences.Keys.barCPU, store: DisplayPreferences.suite) private var barCPU = true
    @AppStorage(DisplayPreferences.Keys.barMemory, store: DisplayPreferences.suite) private var barMemory = true
    @AppStorage(DisplayPreferences.Keys.barDisk, store: DisplayPreferences.suite) private var barDisk = true

    @AppStorage(DisplayPreferences.Keys.cardCPU, store: DisplayPreferences.suite) private var cardCPU = true
    @AppStorage(DisplayPreferences.Keys.cardMemory, store: DisplayPreferences.suite) private var cardMemory = true
    @AppStorage(DisplayPreferences.Keys.cardDisk, store: DisplayPreferences.suite) private var cardDisk = true

    @AppStorage(DisplayPreferences.Keys.pollInterval, store: DisplayPreferences.suite) private var pollInterval = 2.0
    @AppStorage(DisplayPreferences.Keys.uiLanguage, store: DisplayPreferences.suite) private var uiLanguageRaw = AppLanguage.system.storageValue

    var body: some View {
        TabView {
            Form {
                Section {
                    Picker(selection: $uiLanguageRaw) {
                        Text(L10n.string("pref.language.system", locale: locale)).tag(AppLanguage.system.storageValue)
                        Text(L10n.string("pref.language.en", locale: locale)).tag(AppLanguage.english.storageValue)
                        Text(L10n.string("pref.language.zh_hant", locale: locale)).tag(AppLanguage.traditionalChinese.storageValue)
                    } label: {
                        Text(L10n.string("pref.section.language", locale: locale))
                    }
                }

                Section {
                    Toggle(isOn: $barCPU) {
                        Text(L10n.string("pref.toggle.bar.cpu", locale: locale))
                    }
                    Toggle(isOn: $barMemory) {
                        Text(L10n.string("pref.toggle.bar.memory", locale: locale))
                    }
                    Toggle(isOn: $barDisk) {
                        Text(L10n.string("pref.toggle.bar.disk", locale: locale))
                    }
                } header: {
                    Text(L10n.string("pref.section.menubar", locale: locale))
                }
                Section {
                    Toggle(isOn: $cardCPU) {
                        Text(L10n.string("pref.toggle.card.cpu", locale: locale))
                    }
                    Toggle(isOn: $cardMemory) {
                        Text(L10n.string("pref.toggle.card.memory", locale: locale))
                    }
                    Toggle(isOn: $cardDisk) {
                        Text(L10n.string("pref.toggle.card.disk", locale: locale))
                    }
                } header: {
                    Text(L10n.string("pref.section.card", locale: locale))
                }
                Section {
                    Picker(selection: $pollInterval) {
                        Text(L10n.string("pref.poll.1s", locale: locale)).tag(1.0)
                        Text(L10n.string("pref.poll.1_5s", locale: locale)).tag(1.5)
                        Text(L10n.string("pref.poll.2s", locale: locale)).tag(2.0)
                        Text(L10n.string("pref.poll.3s", locale: locale)).tag(3.0)
                    } label: {
                        Text(L10n.string("pref.picker.poll", locale: locale))
                    }
                    .onChange(of: pollInterval) { _, new in
                        metrics.startPolling(interval: new)
                    }
                } header: {
                    Text(L10n.string("pref.section.update", locale: locale))
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label {
                    Text(L10n.string("pref.tab.display", locale: locale))
                } icon: {
                    Image(systemName: "slider.horizontal.3")
                }
            }

            Form {
                Section {
                    Text(L10n.string("pref.about.body", locale: locale))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label {
                    Text(L10n.string("pref.tab.about", locale: locale))
                } icon: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .frame(width: 460, height: 360)
    }
}
