import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english = "en"
    case traditionalChinese = "zh-Hant"

    var id: String { storageValue }

    /// Persisted value for `UserDefaults`.
    var storageValue: String {
        switch self {
        case .system: return "system"
        case .english: return "en"
        case .traditionalChinese: return "zh-Hant"
        }
    }

    static func from(storage raw: String) -> AppLanguage {
        switch raw {
        case AppLanguage.system.storageValue: return .system
        case "en": return .english
        case "zh-Hant": return .traditionalChinese
        default: return .system
        }
    }

    /// Locale applied to SwiftUI for localized strings (`Text`, `String(localized:)`, etc.).
    var locale: Locale {
        switch self {
        case .system: return .autoupdatingCurrent
        case .english: return Locale(identifier: "en")
        case .traditionalChinese: return Locale(identifier: "zh-Hant")
        }
    }
}

enum L10n {
    private static var bundle: Bundle { Bundle.module }

    /// Resolves strings from `Bundle.module` using the given locale (e.g. SwiftUI `Environment.locale`).
    static func string(_ key: String, locale: Locale) -> String {
        String(
            localized: String.LocalizationValue(key),
            bundle: bundle,
            locale: locale
        )
    }

    static func format(_ key: String, locale: Locale, _ arguments: any CVarArg...) -> String {
        let format = String(
            localized: String.LocalizationValue(key),
            bundle: bundle,
            locale: locale
        )
        return String(format: format, locale: locale, arguments: arguments)
    }
}
