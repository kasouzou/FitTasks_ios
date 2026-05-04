import Foundation

struct AdMobConfiguration {
    // 撮影時だけ true にする。通常運用では AdMob バナーを表示するため false を維持する。
    static let isBannerTemporarilyHidden = false

    let appID: String
    let bannerAdUnitID: String

    var hasRequiredIDs: Bool {
        !appID.isEmpty && !bannerAdUnitID.isEmpty
    }

    static let shared = load()

    private static func load() -> AdMobConfiguration {
        // バンドル済みの .env を優先し、ローカルの本番 AdMob 設定で広告を読み込む。
        let envValues = bundledEnvURL().flatMap(loadValues(from:))

        let infoDictionary = Bundle.main.infoDictionary ?? [:]

        let appID = envValues?["APP_ID"] ?? stringValue(for: "GADApplicationIdentifier", in: infoDictionary)
        let bannerAdUnitID = envValues?["AD_UNIT_ID"] ?? stringValue(for: "ADMOB_BANNER_AD_UNIT_ID", in: infoDictionary)

        return AdMobConfiguration(
            appID: appID,
            bannerAdUnitID: bannerAdUnitID
        )
    }

    private static func bundledEnvURL() -> URL? {
        guard let resourceURL = Bundle.main.resourceURL else {
            return nil
        }

        let enumerator = FileManager.default.enumerator(
            at: resourceURL,
            includingPropertiesForKeys: nil
        )

        while let url = enumerator?.nextObject() as? URL {
            if url.lastPathComponent == ".env" {
                return url
            }
        }

        return nil
    }

    private static func loadValues(from url: URL) -> [String: String]? {
        guard let contents = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }

        var values: [String: String] = [:]

        for rawLine in contents.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty, !line.hasPrefix("#"), let separatorIndex = line.firstIndex(of: "=") else {
                continue
            }

            let key = String(line[..<separatorIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
            let rawValue = String(line[line.index(after: separatorIndex)...]).trimmingCharacters(in: .whitespacesAndNewlines)
            let value = rawValue.trimmingCharacters(in: CharacterSet(charactersIn: "\""))

            values[key] = value
        }

        return values
    }

    private static func stringValue(for key: String, in dictionary: [String: Any]) -> String {
        (dictionary[key] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}
