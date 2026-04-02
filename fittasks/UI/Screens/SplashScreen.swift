import SwiftUI

struct SplashScreen: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var showsContent = false
    @State private var pulsesOuterRing = false
    @State private var floatsBadge = false

    private var isDarkMode: Bool {
        colorScheme == .dark
    }

    var body: some View {
        ZStack {
            splashBackground

            VStack(spacing: 26) {
                ZStack {
                    Circle()
                        .fill(outerRingColor)
                        .frame(width: 188, height: 188)
                        .scaleEffect(pulsesOuterRing ? 1.08 : 0.92)
                        .blur(radius: 10)

                    Image("SplashAppIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 31, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 31, style: .continuous)
                                .stroke(iconBorderColor, lineWidth: 1.2)
                        )
                        .shadow(color: iconShadowColor, radius: 24, x: 0, y: 14)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [FitTasksStyle.primaryAccent, FitTasksStyle.secondaryAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 58, height: 8)
                        .offset(y: 94)
                    // 静止しすぎると起動演出に見えないので、バッジ全体をわずかに上下させる。
                    .offset(y: floatsBadge ? -6 : 8)
                }

                VStack(spacing: 10) {
                    Text(store.text(.appName))
                        .font(FitTasksTypography.font(.largeTitle, weight: .bold))
                        .foregroundStyle(titleColor)

                    Text(store.text(.splashCaption))
                        .font(FitTasksTypography.font(.body, weight: .medium))
                        .foregroundStyle(subtitleColor)
                }
            }
            .padding(.horizontal, 28)
            .opacity(showsContent ? 1 : 0)
            .scaleEffect(showsContent ? 1 : 0.94)
        }
        .task {
            withAnimation(.spring(response: 0.72, dampingFraction: 0.8)) {
                showsContent = true
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                pulsesOuterRing = true
            }
            withAnimation(.easeInOut(duration: 1.45).repeatForever(autoreverses: true)) {
                floatsBadge = true
            }
        }
        .ignoresSafeArea()
    }

    private var splashBackground: some View {
        ZStack {
            if isDarkMode {
                LinearGradient(
                    colors: [
                        Color(red: 0.11, green: 0.09, blue: 0.16),
                        Color(red: 0.08, green: 0.10, blue: 0.17),
                        Color(red: 0.14, green: 0.11, blue: 0.16)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(Color(red: 0.88, green: 0.45, blue: 0.63).opacity(0.18))
                    .frame(width: 320, height: 320)
                    .blur(radius: 42)
                    .offset(x: -140, y: -260)

                Circle()
                    .fill(Color(red: 0.42, green: 0.72, blue: 0.89).opacity(0.16))
                    .frame(width: 280, height: 280)
                    .blur(radius: 40)
                    .offset(x: 170, y: -80)

                Circle()
                    .fill(Color(red: 0.98, green: 0.81, blue: 0.43).opacity(0.12))
                    .frame(width: 300, height: 300)
                    .blur(radius: 44)
                    .offset(x: 90, y: 300)
            } else {
                SceneBackground()
            }
        }
    }

    private var outerRingColor: Color {
        isDarkMode
        ? FitTasksStyle.primaryAccent.opacity(0.26)
        : FitTasksStyle.primaryAccent.opacity(0.16)
    }

    private var iconBorderColor: Color {
        isDarkMode ? .white.opacity(0.18) : .white.opacity(0.72)
    }

    private var iconShadowColor: Color {
        isDarkMode
        ? Color.black.opacity(0.34)
        : FitTasksStyle.primaryAccent.opacity(0.18)
    }

    private var titleColor: Color {
        isDarkMode ? .white.opacity(0.96) : .primary
    }

    private var subtitleColor: Color {
        isDarkMode ? .white.opacity(0.72) : .secondary
    }
}
