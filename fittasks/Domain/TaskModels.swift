import Foundation
import SwiftUI

enum TaskPalette: String, CaseIterable, Codable, Identifiable, Sendable {
    case blush
    case sky
    case mint
    case lemon
    case lilac
    case apricot
    case rose
    case ice

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .blush:
            return Color(red: 0.95, green: 0.56, blue: 0.71)
        case .sky:
            return Color(red: 0.50, green: 0.71, blue: 0.98)
        case .mint:
            return Color(red: 0.51, green: 0.82, blue: 0.71)
        case .lemon:
            return Color(red: 0.96, green: 0.83, blue: 0.42)
        case .lilac:
            return Color(red: 0.73, green: 0.64, blue: 0.98)
        case .apricot:
            return Color(red: 0.98, green: 0.69, blue: 0.50)
        case .rose:
            return Color(red: 0.98, green: 0.72, blue: 0.83)
        case .ice:
            return Color(red: 0.59, green: 0.84, blue: 0.90)
        }
    }
}

struct ClockTime: Codable, Hashable, Sendable {
    var hour: Int
    var minute: Int

    init(hour: Int, minute: Int) {
        self.hour = max(0, min(hour, 23))
        self.minute = max(0, min(minute, 59))
    }

    var totalMinutes: Int {
        (hour * 60) + minute
    }

    var label: String {
        String(format: "%02d:%02d", hour, minute)
    }

    func adding(minutes: Int) -> ClockTime {
        let wrapped = ((totalMinutes + minutes) % (24 * 60) + (24 * 60)) % (24 * 60)
        return ClockTime(hour: wrapped / 60, minute: wrapped % 60)
    }

    func date(on referenceDate: Date = Date(), calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        return calendar.date(
            from: DateComponents(
                year: components.year,
                month: components.month,
                day: components.day,
                hour: hour,
                minute: minute
            )
        ) ?? referenceDate
    }

    static let defaultStart = ClockTime(hour: 9, minute: 0)
    static let defaultEnd = ClockTime(hour: 10, minute: 0)
}

struct TaskItem: Identifiable, Codable, Hashable, Sendable {
    var id: UUID = UUID()
    var title: String = ""
    var palette: TaskPalette
    var weight: Int = 1

    var safeWeight: Int {
        max(weight, 1)
    }
}

struct TaskGroup: Identifiable, Codable, Hashable, Sendable {
    var id: UUID = UUID()
    var startTime: ClockTime
    var endTime: ClockTime
    var tasks: [TaskItem]

    var totalDurationMinutes: Int {
        totalDurationSeconds / 60
    }

    var totalDurationSeconds: Int {
        calculateTaskRangeDurationSeconds(startTime: startTime, endTime: endTime)
    }

    var totalWeight: Int {
        tasks.reduce(0) { $0 + $1.safeWeight }
    }

    // The Android reference guarantees minimum time where possible and distributes remainders by weight.
    var allocatedTaskDurationsSeconds: [Int] {
        guard !tasks.isEmpty, totalDurationSeconds > 0 else {
            return Array(repeating: 0, count: tasks.count)
        }

        let weights = tasks.map(\.safeWeight)
        let minimumSecondsPerTask = totalDurationSeconds >= tasks.count ? 1 : 0
        let guaranteedSeconds = minimumSecondsPerTask * tasks.count
        let remainingSeconds = totalDurationSeconds - guaranteedSeconds
        let totalSafeWeight = max(weights.reduce(0, +), 1)

        let shares = weights.map { weight in
            let weightedSeconds = remainingSeconds * weight
            return AllocationShare(
                seconds: weightedSeconds / totalSafeWeight,
                remainder: weightedSeconds % totalSafeWeight
            )
        }

        var result = shares.map { $0.seconds + minimumSecondsPerTask }
        var leftoverSeconds = totalDurationSeconds - result.reduce(0, +)

        for index in shares.indices.sorted(by: { shares[$0].remainder > shares[$1].remainder }) where leftoverSeconds > 0 {
            result[index] += 1
            leftoverSeconds -= 1
        }

        return result
    }

    func durationForTask(at index: Int) -> Int {
        allocatedTaskDurationsSeconds.indices.contains(index) ? allocatedTaskDurationsSeconds[index] : 0
    }

    func durationForTask(id: UUID) -> Int {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            return 0
        }
        return durationForTask(at: index)
    }

    var durationPerTaskSeconds: Int {
        guard !tasks.isEmpty else { return 0 }
        return totalDurationSeconds / tasks.count
    }

    var durationPerTaskMinutes: Int {
        durationPerTaskSeconds / 60
    }
}

private struct AllocationShare {
    let seconds: Int
    let remainder: Int
}

func calculateTaskRangeDurationSeconds(startTime: ClockTime, endTime: ClockTime) -> Int {
    let startMinutes = startTime.totalMinutes
    let endMinutes = endTime.totalMinutes

    if endMinutes > startMinutes {
        return (endMinutes - startMinutes) * 60
    }

    if endMinutes < startMinutes {
        return ((24 * 60) - startMinutes + endMinutes) * 60
    }

    return 0
}

func formatTaskDuration(_ seconds: Int) -> String {
    let safeSeconds = max(seconds, 0)
    return String(format: "%02d:%02d", safeSeconds / 60, safeSeconds % 60)
}
