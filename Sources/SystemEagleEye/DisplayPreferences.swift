import Foundation

enum DisplayPreferences {
    static let suite = UserDefaults(suiteName: "com.systemee.SystemEagleEye") ?? .standard

    enum Keys {
        static let barCPU = "pref.bar.cpu"
        static let barMemory = "pref.bar.memory"
        static let barDisk = "pref.bar.disk"
        static let cardCPU = "pref.card.cpu"
        static let cardMemory = "pref.card.memory"
        static let cardDisk = "pref.card.disk"
        static let pollInterval = "pref.pollInterval"
        static let uiLanguage = "pref.uiLanguage"
    }

    static func registerDefaults() {
        suite.register(defaults: [
            Keys.barCPU: true,
            Keys.barMemory: true,
            Keys.barDisk: true,
            Keys.cardCPU: true,
            Keys.cardMemory: true,
            Keys.cardDisk: true,
            Keys.pollInterval: 2.0,
            Keys.uiLanguage: AppLanguage.system.storageValue
        ])
    }
}
