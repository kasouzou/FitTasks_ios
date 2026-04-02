import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject private var store: AppStore

    @State private var showsLanguageDialog = false
    @State private var showsThemeDialog = false

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                settingCard(
                    title: store.text(.currentLanguage),
                    value: store.preferences.language.map { store.languageLabel(for: $0) } ?? store.text(.languageJapanese),
                    systemImage: "globe",
                    action: { showsLanguageDialog = true }
                )

                settingCard(
                    title: store.text(.themeSetting),
                    value: store.currentThemeLabel(),
                    systemImage: "circle.lefthalf.filled",
                    action: { showsThemeDialog = true }
                )
            }
            .padding(20)
            .padding(.bottom, 40)
        }
        .navigationTitle(store.text(.settingsTitle))
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(store.text(.currentLanguage), isPresented: $showsLanguageDialog) {
            ForEach(store.supportedLanguages) { language in
                Button(store.languageLabel(for: language)) {
                    store.updateLanguage(language)
                }
            }
            Button(store.text(.cancelButton), role: .cancel) {}
        }
        .confirmationDialog(store.text(.themeSetting), isPresented: $showsThemeDialog) {
            ForEach(ThemeMode.allCases) { mode in
                Button(themeLabel(for: mode)) {
                    store.updateThemeMode(mode)
                }
            }
            Button(store.text(.cancelButton), role: .cancel) {}
        }
    }

    private func settingCard(title: String, value: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            GlassCard {
                HStack(spacing: 14) {
                    Image(systemName: systemImage)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(FitTasksStyle.primaryAccent)
                        .frame(width: 42, height: 42)
                        .background(FitTasksStyle.primaryAccent.opacity(0.1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(FitTasksTypography.font(.headline, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text(value)
                            .font(FitTasksTypography.font(.subheadline))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func themeLabel(for themeMode: ThemeMode) -> String {
        switch themeMode {
        case .system:
            return store.text(.themeSystem)
        case .light:
            return store.text(.themeLight)
        case .dark:
            return store.text(.themeDark)
        }
    }
}
