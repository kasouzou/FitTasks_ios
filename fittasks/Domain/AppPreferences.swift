import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Codable, Identifiable, Sendable {
    case japanese = "ja"
    case english = "en"
    case chineseSimplified = "zh-Hans"
    case korean = "ko"

    var id: String { rawValue }

    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

enum ThemeMode: Int, CaseIterable, Codable, Identifiable, Sendable {
    case system = 0
    case light = 1
    case dark = 2

    var id: Int { rawValue }
}

struct AppPreferences: Codable, Sendable {
    var language: AppLanguage?
    var themeMode: ThemeMode = .light
    var isFirstLaunch: Bool = true
}
