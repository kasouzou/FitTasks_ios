import Combine
import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    enum Route: Hashable {
        case taskEdit(UUID?)
        case timer(UUID)
        case settings
    }

    @Published private(set) var taskGroups: [TaskGroup] = []
    @Published private(set) var preferences: AppPreferences = AppPreferences()
    @Published private(set) var isLoaded = false
    @Published var navigationPath: [Route] = []

    private let taskRepository: any TaskRepository
    private let preferenceRepository: any PreferenceRepository
    private var cancellables = Set<AnyCancellable>()
    private var didLoadTasks = false
    private var didLoadPreferences = false

    convenience init() {
        self.init(
            taskRepository: UserDefaultsTaskRepository(),
            preferenceRepository: UserDefaultsPreferenceRepository()
        )
    }

    init(
        taskRepository: any TaskRepository,
        preferenceRepository: any PreferenceRepository
    ) {
        self.taskRepository = taskRepository
        self.preferenceRepository = preferenceRepository

        taskRepository.taskGroupsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] groups in
                self?.taskGroups = groups
                self?.didLoadTasks = true
                self?.refreshLoadState()
            }
            .store(in: &cancellables)

        preferenceRepository.preferencesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] preferences in
                self?.preferences = preferences
                self?.didLoadPreferences = true
                self?.refreshLoadState()
            }
            .store(in: &cancellables)
    }

    var preferredColorScheme: ColorScheme? {
        switch preferences.themeMode {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    var accentTint: Color { FitTasksStyle.primaryAccent }

    var activeLanguage: AppLanguage {
        preferences.language ?? .japanese
    }

    var supportedLanguages: [AppLanguage] {
        [.japanese, .english, .chineseSimplified, .korean]
    }

    var shouldShowLanguageSetup: Bool {
        preferences.isFirstLaunch || preferences.language == nil
    }

    func text(_ key: AppText, _ arguments: CVarArg...) -> String {
        AppLocalization.text(for: key, language: activeLanguage, arguments: arguments)
    }

    func languageLabel(for language: AppLanguage) -> String {
        switch language {
        case .japanese:
            return text(.languageJapanese)
        case .english:
            return text(.languageEnglish)
        case .chineseSimplified:
            return text(.languageChinese)
        case .korean:
            return text(.languageKorean)
        }
    }

    func currentThemeLabel() -> String {
        switch preferences.themeMode {
        case .system:
            return text(.themeSystem)
        case .light:
            return text(.themeLight)
        case .dark:
            return text(.themeDark)
        }
    }

    func taskGroup(id: UUID?) -> TaskGroup? {
        guard let id else { return nil }
        return taskGroups.first(where: { $0.id == id })
    }

    func saveTaskGroup(_ group: TaskGroup) {
        taskRepository.saveTaskGroup(group)
    }

    func deleteTaskGroup(_ group: TaskGroup) {
        taskRepository.deleteTaskGroup(group)
    }

    func completeFirstLaunch(language: AppLanguage) {
        preferenceRepository.updatePreferences { preferences in
            preferences.language = language
            preferences.isFirstLaunch = false
        }
    }

    func updateLanguage(_ language: AppLanguage) {
        preferenceRepository.updatePreferences { preferences in
            preferences.language = language
        }
    }

    func updateThemeMode(_ themeMode: ThemeMode) {
        preferenceRepository.updatePreferences { preferences in
            preferences.themeMode = themeMode
        }
    }

    private func refreshLoadState() {
        isLoaded = didLoadTasks && didLoadPreferences
    }
}
