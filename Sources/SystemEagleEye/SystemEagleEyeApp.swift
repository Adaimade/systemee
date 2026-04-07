import SwiftUI

@main
struct SystemEagleEyeApp: App {

    @StateObject private var metrics = SystemMetricsCollector()
    @AppStorage(DisplayPreferences.Keys.uiLanguage, store: DisplayPreferences.suite) private var uiLanguageRaw = AppLanguage.system.storageValue

    init() {
        DisplayPreferences.registerDefaults()
    }

    private var resolvedLocale: Locale {
        AppLanguage.from(storage: uiLanguageRaw).locale
    }

    var body: some Scene {
        MenuBarExtra {
            InformationCardView()
                .environmentObject(metrics)
                .environment(\.locale, resolvedLocale)
        } label: {
            MenuBarTitleView()
                .environmentObject(metrics)
                .environment(\.locale, resolvedLocale)
        }
        .menuBarExtraStyle(.window)

        Settings {
            PreferencesView()
                .environmentObject(metrics)
                .environment(\.locale, resolvedLocale)
        }
    }
}
