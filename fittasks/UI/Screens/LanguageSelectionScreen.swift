import SwiftUI

struct LanguageSelectionScreen: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 36)

                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(FitTasksStyle.primaryAccent)

                VStack(spacing: 8) {
                    Text(store.text(.welcomeMessage))
                        .font(FitTasksTypography.font(.largeTitle, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text(store.text(.changeLaterHint))
                        .font(FitTasksTypography.font(.body))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)

                GlassCard {
                    VStack(spacing: 14) {
                        ForEach(store.supportedLanguages) { language in
                            Button {
                                store.completeFirstLaunch(language: language)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(store.languageLabel(for: language))
                                            .font(FitTasksTypography.font(.title3, weight: .semibold))
                                            .foregroundStyle(.primary)
                                        Text(language.rawValue)
                                            .font(FitTasksTypography.font(.caption))
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(FitTasksStyle.primaryAccent)
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 16)
                                .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        }
        .scrollIndicators(.hidden)
        .toolbar(.hidden, for: .navigationBar)
    }
}
