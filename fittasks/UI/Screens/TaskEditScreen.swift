import SwiftUI
import UIKit

private let taskTitleMaxLength = 30
private let defaultTaskWeight = 1
private let defaultTaskPalette = TaskPalette.allCases.first ?? .blush

private func normalizedTaskTitle(_ rawTitle: String) -> String {
    rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
}

private func isValidTaskTitle(_ rawTitle: String) -> Bool {
    !normalizedTaskTitle(rawTitle).isEmpty
}

private enum ActiveTimeField: Identifiable {
    case start
    case end

    var id: Int {
        self == .start ? 0 : 1
    }
}

private struct EditableTaskDraft: Identifiable, Equatable {
    let id: UUID
    var title: String
    var palette: TaskPalette
    var weight: Int

    init(task: TaskItem) {
        id = task.id
        title = task.title
        palette = task.palette
        weight = task.weight
    }

    var normalizedTitle: String {
        normalizedTaskTitle(title)
    }

    var taskItem: TaskItem {
        TaskItem(id: id, title: normalizedTitle, palette: palette, weight: weight)
    }
}

private struct TaskEditSnapshot: Equatable {
    var startTime: ClockTime
    var endTime: ClockTime
    var taskDrafts: [EditableTaskDraft]
    var pendingTaskName: String
}

struct TaskEditScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppStore

    let groupID: UUID?

    @State private var startTime = ClockTime.defaultStart
    @State private var endTime = ClockTime.defaultEnd
    @State private var durationInput = "60"
    @State private var taskName = ""
    @State private var selectedWeight = defaultTaskWeight
    @State private var selectedPalette = defaultTaskPalette
    @State private var taskDrafts: [EditableTaskDraft] = []
    @State private var syncedGroupID: UUID?
    @State private var activeTimeField: ActiveTimeField?
    @State private var showsNameLengthWarning = false
    @State private var showsDiscardChangesAlert = false

    private var currentGroup: TaskGroup? {
        store.taskGroup(id: groupID)
    }

    private var isEditMode: Bool {
        groupID != nil
    }

    private var isLoading: Bool {
        isEditMode && !store.isLoaded
    }

    private var isMissingTaskGroup: Bool {
        isEditMode && store.isLoaded && currentGroup == nil
    }

    private var previewGroup: TaskGroup {
        TaskGroup(
            id: groupID ?? UUID(),
            startTime: startTime,
            endTime: endTime,
            tasks: taskDrafts.map(\.taskItem)
        )
    }

    private var canSave: Bool {
        !isLoading &&
            !isMissingTaskGroup &&
            !taskDrafts.isEmpty &&
            taskDrafts.allSatisfy { !$0.normalizedTitle.isEmpty } &&
            previewGroup.totalDurationSeconds > 0
    }

    private var hasPendingNewTaskDraft: Bool {
        isValidTaskTitle(taskName)
    }

    private var discardChangesAlertTitle: String {
        hasPendingNewTaskDraft
            ? store.text(.taskEditPendingDraftExitTitle)
            : store.text(.taskEditDiscardChangesTitle)
    }

    private var discardChangesAlertMessage: String {
        hasPendingNewTaskDraft
            ? store.text(.taskEditPendingDraftExitMessage)
            : store.text(.taskEditDiscardChangesMessage)
    }

    private var baselineSnapshot: TaskEditSnapshot {
        if let group = currentGroup {
            return TaskEditSnapshot(
                startTime: group.startTime,
                endTime: group.endTime,
                taskDrafts: group.tasks.map(EditableTaskDraft.init(task:)),
                pendingTaskName: ""
            )
        }

        return TaskEditSnapshot(
            startTime: .defaultStart,
            endTime: .defaultEnd,
            taskDrafts: [],
            pendingTaskName: ""
        )
    }

    private var currentSnapshot: TaskEditSnapshot {
        // 追加前のタスク名入力も、戻ると失われるため未保存入力として扱う。
        TaskEditSnapshot(
            startTime: startTime,
            endTime: endTime,
            taskDrafts: taskDrafts,
            pendingTaskName: normalizedTaskTitle(taskName)
        )
    }

    private var hasUnsavedChanges: Bool {
        guard !isLoading && !isMissingTaskGroup else { return false }
        return currentSnapshot != baselineSnapshot
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    headerCard

                    if isLoading {
                        loadingCard
                    } else if isMissingTaskGroup {
                        missingCard
                    } else {
                        timeSection
                        taskComposerSection
                        taskListSection
                        saveButton
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 110)
            }
            .scrollIndicators(.hidden)

            FooterBannerAd()
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        // 標準の戻る導線を差し替えて、未保存変更の取りこぼしを防ぐ。
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: handleBackRequest) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                }
                .accessibilityLabel(store.text(.backButton))
            }
        }
        .sheet(item: $activeTimeField) { field in
            TimePickerSheet(
                title: field == .start ? store.text(.startTime) : store.text(.endTime),
                initialTime: field == .start ? startTime : endTime
            ) { selectedTime in
                if field == .start {
                    startTime = selectedTime
                } else {
                    endTime = selectedTime
                }
            }
        }
        .alert(
            discardChangesAlertTitle,
            isPresented: $showsDiscardChangesAlert
        ) {
            Button(store.text(.cancelButton), role: .cancel) {}
            Button(store.text(.taskEditDiscardChangesButton), role: .destructive) {
                dismiss()
            }
            if canSave && !hasPendingNewTaskDraft {
                Button(store.text(.taskEditSaveChangesButton)) {
                    saveCurrentGroup()
                }
            }
        } message: {
            Text(discardChangesAlertMessage)
        }
        .onAppear(perform: syncFromGroupIfNeeded)
        .onChange(of: currentGroup?.id) { _, _ in
            syncFromGroupIfNeeded()
        }
        .onChange(of: startTime) { _, _ in
            durationInput = "\(previewGroup.totalDurationMinutes)"
        }
        .onChange(of: endTime) { _, _ in
            durationInput = "\(previewGroup.totalDurationMinutes)"
        }
    }

    private var headerCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(isEditMode ? store.text(.editTaskTitle) : store.text(.addTaskTitle))
                    .font(FitTasksTypography.font(.largeTitle, weight: .bold))
                Text(store.text(.noTasksDescription))
                    .font(FitTasksTypography.font(.body))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var loadingCard: some View {
        GlassCard {
            HStack(spacing: 12) {
                ProgressView()
                Text(store.text(.editTaskTitle))
                    .font(FitTasksTypography.font(.headline, weight: .semibold))
            }
        }
    }

    private var missingCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(store.text(.taskGroupMissingTitle))
                    .font(FitTasksTypography.font(.headline, weight: .semibold))
                Text(store.text(.taskGroupMissingMessage))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var timeSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: store.text(.timeSettings), subtitle: nil)

                ViewThatFits {
                    HStack(spacing: 12) {
                        timeCard(title: store.text(.startTime), value: startTime.label) {
                            activeTimeField = .start
                        }
                        timeCard(title: store.text(.endTime), value: endTime.label) {
                            activeTimeField = .end
                        }
                    }
                    VStack(spacing: 12) {
                        timeCard(title: store.text(.startTime), value: startTime.label) {
                            activeTimeField = .start
                        }
                        timeCard(title: store.text(.endTime), value: endTime.label) {
                            activeTimeField = .end
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(store.text(.durationLabel))
                        .font(FitTasksTypography.font(.subheadline, weight: .semibold))

                    TextField(
                        store.text(.durationLabel),
                        text: Binding(
                            get: { durationInput },
                            set: { newValue in
                                let filtered = newValue.filter(\.isNumber)
                                durationInput = filtered
                                if let minutes = Int(filtered), minutes >= 0 {
                                    endTime = startTime.adding(minutes: minutes)
                                }
                            }
                        )
                    )
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)

                    Text(store.text(.totalDurationFormat, previewGroup.totalDurationMinutes))
                        .font(FitTasksTypography.font(.footnote, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var taskComposerSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: store.text(.addTaskSection), subtitle: nil)

                VStack(alignment: .leading, spacing: 8) {
                    LimitedTextField(
                        placeholder: store.text(.taskNameLabel),
                        text: $taskName,
                        maxLength: taskTitleMaxLength,
                        showsOverflowWarning: $showsNameLengthWarning
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)

                    taskNameInputFooter(
                        currentCount: taskName.count,
                        warningText: taskNameValidationMessage(
                            title: taskName,
                            lengthWarningText: store.text(.taskNameLengthWarningFormat, taskTitleMaxLength),
                            requiredWarningText: store.text(.taskNameRequiredWarning),
                            showsLengthWarning: showsNameLengthWarning,
                            showsRequiredWarning: !taskName.isEmpty
                        )
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(store.text(.taskWeightLabel))
                        .font(FitTasksTypography.font(.subheadline, weight: .semibold))

                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { weight in
                            Button {
                                selectedWeight = weight
                            } label: {
                                Image(systemName: weight <= selectedWeight ? "star.fill" : "star")
                                    .font(.title3)
                                    .foregroundStyle(weight <= selectedWeight ? selectedPalette.color : .secondary)
                                    .frame(width: 34, height: 34)
                                    .background(.white.opacity(0.7), in: Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(store.text(.taskColorLabel))
                        .font(FitTasksTypography.font(.subheadline, weight: .semibold))

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 42), spacing: 10)], spacing: 10) {
                        ForEach(TaskPalette.allCases) { palette in
                            Button {
                                selectedPalette = palette
                            } label: {
                                Circle()
                                    .fill(palette.color)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(.white.opacity(selectedPalette == palette ? 1 : 0), lineWidth: 3)
                                    )
                                    .frame(width: 34, height: 34)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Button(store.text(.addButton)) {
                    addTask(named: taskName)
                }
                .buttonStyle(.borderedProminent)
                .tint(FitTasksStyle.primaryAccent)
                .disabled(!isValidTaskTitle(taskName))
            }
        }
    }

    private var taskListSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(
                    title: store.text(.taskListCountFormat, taskDrafts.count),
                    subtitle: nil
                )

                if taskDrafts.isEmpty {
                    Text(store.text(.noTasksTitle))
                        .font(FitTasksTypography.font(.subheadline))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(taskDrafts.enumerated()), id: \.element.id) { index, task in
                        EditableTaskRow(
                            task: $taskDrafts[index],
                            durationText: formatTaskDuration(previewGroup.durationForTask(at: index)),
                            onDelete: {
                                taskDrafts.removeAll { $0.id == task.id }
                            }
                        )
                    }
                }
            }
        }
    }

    private var saveButton: some View {
        Button(store.text(.saveButton)) {
            saveCurrentGroup()
        }
        .buttonStyle(.borderedProminent)
        .tint(FitTasksStyle.primaryAccent)
        .controlSize(.large)
        .disabled(!canSave)
    }

    private func timeCard(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(FitTasksTypography.font(.caption, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(FitTasksTypography.font(.title2, weight: .bold))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func syncFromGroupIfNeeded() {
        guard let group = currentGroup else { return }
        guard syncedGroupID != group.id else { return }
        startTime = group.startTime
        endTime = group.endTime
        durationInput = "\(group.totalDurationMinutes)"
        taskDrafts = group.tasks.map(EditableTaskDraft.init(task:))
        syncedGroupID = group.id
    }

    private func addTask(named rawTitle: String) {
        let title = normalizedTaskTitle(rawTitle)
        guard isValidTaskTitle(title) else { return }

        taskDrafts.append(
            EditableTaskDraft(
                task: TaskItem(
                    title: title,
                    palette: selectedPalette,
                    weight: selectedWeight
                )
            )
        )

        taskName = ""
        selectedWeight = defaultTaskWeight
        showsNameLengthWarning = false
    }

    private func handleBackRequest() {
        if hasUnsavedChanges {
            showsDiscardChangesAlert = true
            return
        }

        dismiss()
    }

    private func saveCurrentGroup() {
        // 離脱前保存からも同じ保存条件を通し、空グループの生成を防ぐ。
        guard canSave else { return }

        let group = TaskGroup(
            id: groupID ?? UUID(),
            startTime: startTime,
            endTime: endTime,
            tasks: taskDrafts.map(\.taskItem)
        )
        store.saveTaskGroup(group)
        // 保存経路を一箇所へ寄せて、通常保存と離脱前保存の挙動差分をなくす。
        dismiss()
    }
}

private struct EditableTaskRow: View {
    @EnvironmentObject private var store: AppStore

    @Binding var task: EditableTaskDraft
    let durationText: String
    let onDelete: () -> Void

    @State private var showsLengthWarning = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(task.palette.color)
                    .frame(width: 16, height: 16)

                VStack(alignment: .leading, spacing: 6) {
                    LimitedTextField(
                        placeholder: store.text(.taskNameLabel),
                        text: $task.title,
                        maxLength: taskTitleMaxLength,
                        showsOverflowWarning: $showsLengthWarning
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)

                    taskNameInputFooter(
                        currentCount: task.title.count,
                        warningText: taskNameValidationMessage(
                            title: task.title,
                            lengthWarningText: store.text(.taskNameLengthWarningFormat, taskTitleMaxLength),
                            requiredWarningText: store.text(.taskNameRequiredWarning),
                            showsLengthWarning: showsLengthWarning,
                            showsRequiredWarning: true
                        ),
                        warningFont: .caption2
                    )
                }

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }

            HStack {
                Text(durationText)
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { weight in
                        Button {
                            task.weight = weight
                        } label: {
                            Image(systemName: weight <= max(task.weight, 1) ? "star.fill" : "star")
                                .foregroundStyle(weight <= max(task.weight, 1) ? task.palette.color : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .background(task.palette.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct LimitedTextField: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    let maxLength: Int
    @Binding var showsOverflowWarning: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.delegate = context.coordinator
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textDidChange(_:)),
            for: .editingChanged
        )
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.placeholder = placeholder
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        private let parent: LimitedTextField

        init(_ parent: LimitedTextField) {
            self.parent = parent
        }

        @objc func textDidChange(_ textField: UITextField) {
            let currentText = textField.text ?? ""
            if currentText != parent.text {
                parent.text = currentText
            }
            if currentText.count < parent.maxLength, parent.showsOverflowWarning {
                parent.showsOverflowWarning = false
            }
        }

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else {
                return false
            }

            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            if updatedText.count <= parent.maxLength {
                parent.showsOverflowWarning = false
                return true
            }

            let remainingCount = parent.maxLength - (currentText.count - currentText[stringRange].count)
            if remainingCount > 0, !string.isEmpty {
                let allowedText = String(string.prefix(remainingCount))
                let truncatedText = currentText.replacingCharacters(in: stringRange, with: allowedText)

                // 貼り付け時も残り文字数ぶんだけ反映して、見た目上も30文字を超えないようにする。
                textField.text = truncatedText
                parent.text = truncatedText
            }

            parent.showsOverflowWarning = true
            return false
        }
    }
}

@ViewBuilder
private func taskNameInputFooter(
    currentCount: Int,
    warningText: String?,
    warningFont: Font = .caption
) -> some View {
    HStack(alignment: .firstTextBaseline) {
        if let warningText, !warningText.isEmpty {
            Text(warningText)
                .font(warningFont)
                .foregroundStyle(.red)
        }

        Spacer(minLength: 8)

        // 入力は30文字で切り詰めるため、カウンターも常に実際に保持している文字数を示す。
        Text("\(currentCount)/\(taskTitleMaxLength)")
            .font(.caption.monospacedDigit())
            .foregroundStyle(currentCount >= taskTitleMaxLength ? FitTasksStyle.primaryAccent : .secondary)
    }
}

private func taskNameValidationMessage(
    title: String,
    lengthWarningText: String,
    requiredWarningText: String,
    showsLengthWarning: Bool,
    showsRequiredWarning: Bool
) -> String? {
    if showsLengthWarning {
        return lengthWarningText
    }

    if showsRequiredWarning && !isValidTaskTitle(title) {
        return requiredWarningText
    }

    return nil
}

private struct TimePickerSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let title: String
    let initialTime: ClockTime
    let onSelect: (ClockTime) -> Void

    @State private var selectedDate: Date

    init(title: String, initialTime: ClockTime, onSelect: @escaping (ClockTime) -> Void) {
        self.title = title
        self.initialTime = initialTime
        self.onSelect = onSelect
        _selectedDate = State(initialValue: initialTime.date())
    }

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    title,
                    selection: $selectedDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(store.text(.cancelButton)) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(store.text(.okButton)) {
                        let components = Calendar.current.dateComponents([.hour, .minute], from: selectedDate)
                        onSelect(
                            ClockTime(
                                hour: components.hour ?? initialTime.hour,
                                minute: components.minute ?? initialTime.minute
                            )
                        )
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
