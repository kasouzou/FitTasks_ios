import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum FitTasksStyle {
    static let primaryAccent = Color(red: 0.91, green: 0.38, blue: 0.56)
    static let secondaryAccent = Color(red: 0.42, green: 0.72, blue: 0.89)
    static let shell = Color.white.opacity(0.7)
    static let shellBorder = Color.white.opacity(0.35)
    static let cardShadow = Color.black.opacity(0.08)
}

enum FitTasksTypography {
    static func font(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        #if canImport(UIKit)
        let pointSize = UIFont.preferredFont(forTextStyle: style.uiTextStyle).pointSize
        if let fontName = preferredFontName(for: weight) {
            return .custom(fontName, size: pointSize, relativeTo: style)
        }
        #endif
        return .system(style, design: .rounded, weight: weight)
    }

    static func heroTitleFont() -> Font {
        #if canImport(UIKit)
        if let fontName = preferredFontName(for: .black) {
            return .custom(fontName, size: 40, relativeTo: .largeTitle)
        }
        #endif
        return .system(size: 40, weight: .black, design: .rounded)
    }

    #if canImport(UIKit)
    // ZenMaruGothic が同梱されたらそれを最優先し、未同梱時は iOS 標準の丸ゴへ寄せる。
    private static func preferredFontName(for weight: Font.Weight) -> String? {
        let candidates: [String]
        switch weight {
        case .bold, .heavy, .black, .semibold:
            candidates = ["ZenMaruGothic-Bold", "HiraMaruProN-W4"]
        case .medium:
            candidates = ["ZenMaruGothic-Medium", "HiraMaruProN-W4"]
        default:
            candidates = ["ZenMaruGothic-Regular", "HiraMaruProN-W4"]
        }

        return candidates.first { UIFont(name: $0, size: 16) != nil }
    }
    #endif
}

#if canImport(UIKit)
private extension Font.TextStyle {
    var uiTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: .largeTitle
        case .title: .title1
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .callout: .callout
        case .caption: .caption1
        case .caption2: .caption2
        case .footnote: .footnote
        default: .body
        }
    }
}
#endif

struct SceneBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.95, blue: 0.97),
                    Color(red: 0.99, green: 0.94, blue: 0.97),
                    Color(red: 1.0, green: 0.96, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color(red: 0.99, green: 0.76, blue: 0.85).opacity(0.52))
                .frame(width: 320, height: 320)
                .blur(radius: 32)
                .offset(x: -150, y: -290)

            Circle()
                .fill(Color(red: 0.98, green: 0.84, blue: 0.91).opacity(0.4))
                .frame(width: 300, height: 300)
                .blur(radius: 34)
                .offset(x: 170, y: -110)

            Circle()
                .fill(Color(red: 1.0, green: 0.88, blue: 0.92).opacity(0.36))
                .frame(width: 360, height: 360)
                .blur(radius: 36)
                .offset(x: 100, y: 320)
        }
        .ignoresSafeArea()
    }
}

struct GlassCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(FitTasksStyle.shellBorder, lineWidth: 1)
            )
            .shadow(color: FitTasksStyle.cardShadow, radius: 18, x: 0, y: 12)
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(FitTasksTypography.font(.title3, weight: .bold))
                .foregroundStyle(.primary)
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(FitTasksTypography.font(.subheadline))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension Color {
    var accessibleForeground: Color {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let luminance = (0.299 * red) + (0.587 * green) + (0.114 * blue)
        return luminance > 0.66 ? .black : .white
        #else
        return .primary
        #endif
    }
}
