import Combine
import SwiftUI

@MainActor
final class TimerViewModel: ObservableObject {
    struct State {
        var taskGroup: TaskGroup
        var currentTaskID: UUID?
        var remainingSeconds: Int
        var isRunning: Bool
        var isFinished: Bool
        var completedTaskIDs: Set<UUID>
    }

    @Published private(set) var state: State

    private var timerCancellable: AnyCancellable?
    private var elapsedInCurrentTask = 0

    init(taskGroup: TaskGroup) {
        let firstTask = taskGroup.tasks.first
        state = State(
            taskGroup: taskGroup,
            currentTaskID: firstTask?.id,
            remainingSeconds: firstTask.map { taskGroup.durationForTask(id: $0.id) } ?? 0,
            isRunning: false,
            isFinished: taskGroup.tasks.isEmpty,
            completedTaskIDs: []
        )

        if !taskGroup.tasks.isEmpty {
            startTimer()
        }
    }

    var currentTask: TaskItem? {
        guard let currentTaskID = state.currentTaskID else { return nil }
        return state.taskGroup.tasks.first(where: { $0.id == currentTaskID })
    }

    var currentTaskIndex: Int? {
        guard let currentTaskID = state.currentTaskID else { return nil }
        return state.taskGroup.tasks.firstIndex(where: { $0.id == currentTaskID })
    }

    var currentAllocation: Int {
        guard let currentTaskID = state.currentTaskID else { return 0 }
        return state.taskGroup.durationForTask(id: currentTaskID)
    }

    func startTimer() {
        guard !state.isFinished, !state.isRunning else { return }
        state.isRunning = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func pauseTimer() {
        state.isRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func stopTimer() {
        pauseTimer()
    }

    func skipTask() {
        advanceToNextTask()
    }

    func isDone(_ task: TaskItem) -> Bool {
        state.completedTaskIDs.contains(task.id)
    }

    func isCurrent(_ task: TaskItem) -> Bool {
        state.currentTaskID == task.id
    }

    private func tick() {
        guard state.isRunning, !state.isFinished else { return }

        if state.remainingSeconds > 0 {
            state.remainingSeconds -= 1
            elapsedInCurrentTask += 1
        }

        if state.remainingSeconds <= 0 {
            advanceToNextTask()
        }
    }

    private func advanceToNextTask() {
        if let currentTaskID = state.currentTaskID {
            state.completedTaskIDs.insert(currentTaskID)
        }

        if let nextTask = state.taskGroup.tasks.first(where: { !state.completedTaskIDs.contains($0.id) }) {
            state.currentTaskID = nextTask.id
            elapsedInCurrentTask = 0
            state.remainingSeconds = state.taskGroup.durationForTask(id: nextTask.id)
        } else {
            finishTimer()
        }
    }

    private func finishTimer() {
        pauseTimer()
        state.isFinished = true
        state.currentTaskID = nil
        state.remainingSeconds = 0
    }
}

@MainActor
struct TimerScreen: View {
    @EnvironmentObject private var store: AppStore

    let onClose: () -> Void

    @StateObject private var viewModel: TimerViewModel
    @State private var showsTaskListSheet = false
    @State private var showsExitConfirmation = false
    @State private var showsSkipHint = false

    init(groupID _: UUID, initialGroup: TaskGroup, onClose: @escaping () -> Void) {
        self.onClose = onClose
        _viewModel = StateObject(wrappedValue: TimerViewModel(taskGroup: initialGroup))
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    if proxy.size.width > proxy.size.height {
                        landscapeLayout(proxy: proxy)
                    } else {
                        portraitLayout
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                // 一覧画面と同様に、広告帯の下側が少し見える余白は ScrollView 本体ではなく
                // スクロール内容側へ付けないと、終端の見え方として反映されない。
                .padding(.bottom, 132)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                FooterBannerAd()
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
            }
            .padding(.bottom, 10)
            .background(.clear)
        }
        .navigationTitle(store.text(.timerTitle))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    handleBackRequest()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                }
                .accessibilityLabel(store.text(.backButton))
            }
        }
        .onDisappear {
            viewModel.stopTimer()
        }
        .sheet(isPresented: $showsTaskListSheet) {
            NavigationStack {
                TaskListSheetContent(viewModel: viewModel)
                    .environmentObject(store)
            }
            .presentationDetents([.large])
        }
        .alert(store.text(.timerExitConfirmTitle), isPresented: $showsExitConfirmation) {
            Button(store.text(.cancelButton), role: .cancel) {}
            Button(store.text(.timerExitConfirmButton), role: .destructive) {
                onClose()
            }
        } message: {
            Text(store.text(.timerExitConfirmMessage))
        }
        .overlay(alignment: .bottom) {
            if showsSkipHint {
                Text(store.text(.skipHint))
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, 84)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.84), value: showsSkipHint)
    }

    private var portraitLayout: some View {
        VStack(spacing: 18) {
            heroPanel
            taskListPanel
        }
    }

    private func landscapeLayout(proxy: GeometryProxy) -> some View {
        HStack(alignment: .top, spacing: 18) {
            heroPanel
                .frame(maxWidth: .infinity)

            taskListPanel
                .frame(width: min(max(proxy.size.width * 0.34, 300), 380))
        }
    }

    private var heroPanel: some View {
        GlassCard {
            VStack(spacing: 18) {
                Text(viewModel.state.taskGroup.startTime.label + " - " + viewModel.state.taskGroup.endTime.label)
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.secondary)

                if viewModel.state.isFinished {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 74))
                            .foregroundStyle(FitTasksStyle.primaryAccent)

                        Text(store.text(.greatJob))
                            .font(FitTasksTypography.font(.title, weight: .bold))

                        Text(store.text(.allTasksCompleted))
                            .font(FitTasksTypography.font(.body))
                            .foregroundStyle(.secondary)

                        Button(store.text(.backToList), action: onClose)
                            .buttonStyle(.borderedProminent)
                            .tint(FitTasksStyle.primaryAccent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                } else if let currentTask = viewModel.currentTask {
                    TimerHeroView(
                        task: currentTask,
                        allocatedDurationSeconds: viewModel.currentAllocation,
                        remainingSeconds: viewModel.state.remainingSeconds,
                        isRunning: viewModel.state.isRunning,
                        onToggle: {
                            if viewModel.state.isRunning {
                                viewModel.pauseTimer()
                            } else {
                                viewModel.startTimer()
                            }
                        },
                        onSkipTap: showSkipHintBriefly,
                        onSkipLongPress: { viewModel.skipTask() }
                    )
                }
            }
        }
    }

    private var taskListPanel: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    SectionHeader(title: store.text(.nextTasks), subtitle: nil)

                    Spacer(minLength: 10)

                    VStack(alignment: .trailing, spacing: 8) {
                        Button(store.text(.openTaskListSheet)) {
                            showsTaskListSheet = true
                        }
                        .buttonStyle(.bordered)
                    }
                }

                ForEach(viewModel.state.taskGroup.tasks) { task in
                    TimerTaskRow(
                        task: task,
                        allocatedDurationSeconds: viewModel.state.taskGroup.durationForTask(id: task.id),
                        isCurrent: viewModel.isCurrent(task),
                        isDone: viewModel.isDone(task)
                    )
                }
            }
        }
    }

    private func handleBackRequest() {
        if viewModel.state.isRunning && !viewModel.state.isFinished {
            showsExitConfirmation = true
        } else {
            onClose()
        }
    }

    private func showSkipHintBriefly() {
        showsSkipHint = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            showsSkipHint = false
        }
    }
}

private struct TimerHeroView: View {
    let task: TaskItem
    let allocatedDurationSeconds: Int
    let remainingSeconds: Int
    let isRunning: Bool
    let onToggle: () -> Void
    let onSkipTap: () -> Void
    let onSkipLongPress: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                Text(task.title)
                    .font(FitTasksTypography.font(.title, weight: .bold))
                    .lineLimit(1)
                    .foregroundStyle(task.palette.color.accessibleForeground)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(task.palette.color, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                HStack(spacing: 4) {
                    ForEach(0..<task.safeWeight, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .foregroundStyle(task.palette.color)
                    }
                }

                Text(formatTaskDuration(allocatedDurationSeconds))
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            ZStack {
                Circle()
                    .fill(task.palette.color.opacity(0.12))
                Circle()
                    .stroke(task.palette.color.opacity(0.25), lineWidth: 18)

                Text(formatTaskDuration(remainingSeconds))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(task.palette.color)
            }
            .frame(width: 220, height: 220)

            HStack(spacing: 18) {
                Button(action: onToggle) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(task.palette.color.accessibleForeground)
                        .frame(width: 76, height: 76)
                        .background(task.palette.color, in: Circle())
                }
                .buttonStyle(.plain)

                LongPressSkipButton(
                    onTap: onSkipTap,
                    onLongPress: onSkipLongPress
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct LongPressSkipButton: View {
    let onTap: () -> Void
    let onLongPress: () -> Void

    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.7))
                .frame(width: 64, height: 64)

            Image(systemName: "forward.end.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
        }
        .contentShape(Circle())
        .onTapGesture(perform: onTap)
        .onLongPressGesture(minimumDuration: 0.75, perform: onLongPress)
    }
}

private struct TimerTaskRow: View {
    let task: TaskItem
    let allocatedDurationSeconds: Int
    let isCurrent: Bool
    let isDone: Bool

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(isDone ? .gray.opacity(0.45) : task.palette.color)
                .frame(width: 14, height: 14)

            VStack(alignment: .leading, spacing: 5) {
                Text(task.title)
                    .font(FitTasksTypography.font(.subheadline, weight: isCurrent ? .bold : .medium))
                    .lineLimit(1)
                    .foregroundStyle(isDone ? .secondary : .primary)
                    .strikethrough(isDone)

                HStack(spacing: 4) {
                    ForEach(0..<task.safeWeight, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(isDone ? .secondary : task.palette.color)
                    }
                }
            }

            Spacer()

            if isDone {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.secondary)
            } else {
                Text(formatTaskDuration(allocatedDurationSeconds))
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(
            (isCurrent ? task.palette.color.opacity(0.14) : Color.white.opacity(0.62)),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }
}

private struct TaskListSheetContent: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.text(.taskListSheetTitle))
                            .font(FitTasksTypography.font(.title2, weight: .bold))
                        Text(store.text(.taskListSheetCountFormat, viewModel.state.taskGroup.tasks.count))
                            .font(FitTasksTypography.font(.subheadline))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button(store.text(.closeButton)) {
                        dismiss()
                    }
                }

                ForEach(viewModel.state.taskGroup.tasks) { task in
                    TimerTaskRow(
                        task: task,
                        allocatedDurationSeconds: viewModel.state.taskGroup.durationForTask(id: task.id),
                        isCurrent: viewModel.isCurrent(task),
                        isDone: viewModel.isDone(task)
                    )
                }
            }
            .padding(20)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
