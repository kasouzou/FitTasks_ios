import SwiftUI

#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

struct FooterBannerAd: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        Group {
#if canImport(GoogleMobileAds)
            BannerAdContainer()
                .frame(height: 56)
#else
            HStack(spacing: 10) {
                Image(systemName: "megaphone.fill")
                    .foregroundStyle(FitTasksStyle.primaryAccent)
                Text(store.text(.adPlaceholder))
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(.white.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
            )
#endif
        }
    }
}

#if canImport(GoogleMobileAds)
private struct BannerAdContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let configuration = AdMobConfiguration.shared

        guard !configuration.bannerAdUnitID.isEmpty else {
            return container
        }

        let bannerView = GADBannerView(adSize: currentAdSize())
        bannerView.adUnitID = configuration.bannerAdUnitID
        bannerView.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        bannerView.load(GADRequest())
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    private func currentAdSize() -> GADAdSize {
        let width = UIScreen.main.bounds.width
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
    }
}
#endif
