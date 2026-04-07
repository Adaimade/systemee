import SwiftUI

@main
struct SystemEagleEyeApp: App {

    @StateObject private var metrics = SystemMetricsCollector()

    init() {
        DisplayPreferences.registerDefaults()
    }

    var body: some Scene {
        MenuBarExtra {
            InformationCardView()
                .environmentObject(metrics)
        } label: {
            MenuBarTitleView()
                .environmentObject(metrics)
        }
        .menuBarExtraStyle(.window)

        Settings {
            PreferencesView()
                .environmentObject(metrics)
        }
    }
}
