import Combine
import Foundation

protocol TaskRepository: AnyObject {
    var taskGroupsPublisher: AnyPublisher<[TaskGroup], Never> { get }
    func saveTaskGroup(_ group: TaskGroup)
    func deleteTaskGroup(_ group: TaskGroup)
}

protocol PreferenceRepository: AnyObject {
    var preferencesPublisher: AnyPublisher<AppPreferences, Never> { get }
    func updatePreferences(_ update: (inout AppPreferences) -> Void)
}

@MainActor
final class UserDefaultsTaskRepository: ObservableObject, TaskRepository {
    private enum Keys {
        static let taskGroups = "com.kasouzou.fittasks.taskGroups"
    }

    @Published private var taskGroups: [TaskGroup]
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.taskGroups = Self.loadTaskGroups(from: userDefaults, decoder: decoder)
    }

    var taskGroupsPublisher: AnyPublisher<[TaskGroup], Never> {
        $taskGroups.eraseToAnyPublisher()
    }

    func saveTaskGroup(_ group: TaskGroup) {
        var updated = taskGroups
        if let index = updated.firstIndex(where: { $0.id == group.id }) {
            updated[index] = group
        } else {
            updated.append(group)
        }
        taskGroups = sortGroups(updated)
        persist()
    }

    func deleteTaskGroup(_ group: TaskGroup) {
        taskGroups.removeAll { $0.id == group.id }
        persist()
    }

    private func persist() {
        guard let data = try? encoder.encode(taskGroups) else {
            return
        }
        userDefaults.set(data, forKey: Keys.taskGroups)
    }

    private func sortGroups(_ groups: [TaskGroup]) -> [TaskGroup] {
        groups.sorted { lhs, rhs in
            if lhs.startTime.totalMinutes == rhs.startTime.totalMinutes {
                return lhs.id.uuidString < rhs.id.uuidString
            }
            return lhs.startTime.totalMinutes < rhs.startTime.totalMinutes
        }
    }

    private static func loadTaskGroups(from userDefaults: UserDefaults, decoder: JSONDecoder) -> [TaskGroup] {
        guard
            let data = userDefaults.data(forKey: Keys.taskGroups),
            let decoded = try? decoder.decode([TaskGroup].self, from: data)
        else {
            return []
        }
        return decoded
    }
}

@MainActor
final class UserDefaultsPreferenceRepository: ObservableObject, PreferenceRepository {
    private enum Keys {
        static let preferences = "com.kasouzou.fittasks.preferences"
    }

    @Published private var preferences: AppPreferences
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.preferences = Self.loadPreferences(from: userDefaults, decoder: decoder)
    }

    var preferencesPublisher: AnyPublisher<AppPreferences, Never> {
        $preferences.eraseToAnyPublisher()
    }

    func updatePreferences(_ update: (inout AppPreferences) -> Void) {
        var nextValue = preferences
        update(&nextValue)
        preferences = nextValue
        persist()
    }

    private func persist() {
        guard let data = try? encoder.encode(preferences) else {
            return
        }
        userDefaults.set(data, forKey: Keys.preferences)
    }

    private static func loadPreferences(from userDefaults: UserDefaults, decoder: JSONDecoder) -> AppPreferences {
        guard
            let data = userDefaults.data(forKey: Keys.preferences),
            let decoded = try? decoder.decode(AppPreferences.self, from: data)
        else {
            return AppPreferences()
        }
        return decoded
    }
}
