import Foundation
import SwiftUI

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

    /// Applied to SwiftUI for locale-sensitive formatting (numbers, dates).
    var locale: Locale {
        switch self {
        case .system: return .autoupdatingCurrent
        case .english: return Locale(identifier: "en")
        case .traditionalChinese: return Locale(identifier: "zh-Hant")
        }
    }
}

// MARK: - Environment (drives explicit string-table lookup; see L10n)

private enum AppLanguageKey: EnvironmentKey {
    static let defaultValue = AppLanguage.english
}

extension EnvironmentValues {
    /// UI copy follows this setting. `String(localized:bundle:locale:)` ignores `locale` for many SPM bundles and falls back to the system language.
    var appLanguage: AppLanguage {
        get { self[AppLanguageKey.self] }
        set { self[AppLanguageKey.self] = newValue }
    }
}

// MARK: - L10n (load `Localizable.strings` for the chosen language)

enum L10n {
    private static let bundle = Bundle.module
    private static var tableCache: [String: [String: String]] = [:]
    private static let cacheLock = NSLock()

    /// SPM emits `zh-hant.lproj`; try both spellings.
    private static func searchOrder(for language: AppLanguage) -> [String] {
        switch language {
        case .english:
            return ["en"]
        case .traditionalChinese:
            return ["zh-Hant", "zh-hant"]
        case .system:
            return systemPreferredSearchOrder()
        }
    }

    private static func systemPreferredSearchOrder() -> [String] {
        for id in Locale.preferredLanguages {
            let l = id.lowercased().replacingOccurrences(of: "_", with: "-")
            if l.hasPrefix("zh-hans") || l.hasPrefix("zh-cn") { return ["en"] }
            if l.hasPrefix("zh-hant") || l.hasPrefix("zh-tw") || l.hasPrefix("zh-hk") || l.hasPrefix("zh-mo") {
                return ["zh-Hant", "zh-hant"]
            }
            if l.hasPrefix("zh") { return ["zh-Hant", "zh-hant"] }
            if l.hasPrefix("en") { return ["en"] }
        }
        return ["en"]
    }

    private static func loadTable(searchOrder: [String]) -> [String: String] {
        let cacheKey = searchOrder.joined(separator: "|")
        cacheLock.lock()
        defer { cacheLock.unlock() }
        if let hit = tableCache[cacheKey] { return hit }

        for loc in searchOrder {
            if let url = bundle.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: loc),
               let dict = NSDictionary(contentsOf: url) as? [String: String] {
                tableCache[cacheKey] = dict
                return dict
            }
        }
        if searchOrder != ["en"],
           let url = bundle.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: "en"),
           let dict = NSDictionary(contentsOf: url) as? [String: String] {
            tableCache[cacheKey] = dict
            return dict
        }
        tableCache[cacheKey] = [:]
        return [:]
    }

    private static func dictionary(for language: AppLanguage) -> [String: String] {
        loadTable(searchOrder: searchOrder(for: language))
    }

    static func string(_ key: String, language: AppLanguage) -> String {
        let d = dictionary(for: language)
        if let v = d[key] { return v }
        if let url = bundle.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: "en"),
           let en = NSDictionary(contentsOf: url) as? [String: String],
           let v = en[key] {
            return v
        }
        return key
    }

    static func format(_ key: String, language: AppLanguage, _ arguments: any CVarArg...) -> String {
        let format = string(key, language: language)
        let loc: Locale =
            switch language {
            case .english: Locale(identifier: "en_US")
            case .traditionalChinese: Locale(identifier: "zh_TW")
            case .system: Locale.current
            }
        return String(format: format, locale: loc, arguments: arguments)
    }
}
