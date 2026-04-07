import SwiftUI

@main
struct SystemEagleEyeApp: App {

    @StateObject private var metrics = SystemMetricsCollector()
    @AppStorage(DisplayPreferences.Keys.uiLanguage, store: DisplayPreferences.suite) private var uiLanguageRaw = AppLanguage.english.storageValue

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
                .environment(\.appLanguage, AppLanguage.from(storage: uiLanguageRaw))
        } label: {
            MenuBarTitleView()
                .environmentObject(metrics)
                .environment(\.locale, resolvedLocale)
                .environment(\.appLanguage, AppLanguage.from(storage: uiLanguageRaw))
        }
        .menuBarExtraStyle(.window)

        Settings {
            PreferencesView()
                .environmentObject(metrics)
                .environment(\.locale, resolvedLocale)
                .environment(\.appLanguage, AppLanguage.from(storage: uiLanguageRaw))
        }
    }
}
