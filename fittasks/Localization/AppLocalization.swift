import Foundation

enum AppText: String {
    case appName
    case splashCaption
    case welcomeMessage
    case changeLaterHint
    case languageJapanese
    case languageEnglish
    case languageChinese
    case languageKorean
    case noTasksTitle
    case noTasksDescription
    case noTasksPrompt
    case createFirstTask
    case addTaskTitle
    case editTaskTitle
    case timeSettings
    case startTime
    case endTime
    case durationLabel
    case totalDurationFormat
    case addTaskSection
    case taskNameLabel
    case taskWeightLabel
    case taskColorLabel
    case totalTasksLabel
    case totalTaskCardsLabel
    case addButton
    case taskListCountFormat
    case saveButton
    case backButton
    case closeButton
    case cancelButton
    case okButton
    case selectTimeTitle
    case taskGroupMissingTitle
    case taskGroupMissingMessage
    case deleteTaskGroupConfirmTitle
    case deleteButton
    case editButton
    case settingsTitle
    case currentLanguage
    case themeSetting
    case themeSystem
    case themeLight
    case themeDark
    case timerTitle
    case nextTasks
    case openTaskListSheet
    case timerExitConfirmTitle
    case timerExitConfirmMessage
    case timerExitConfirmButton
    case pauseButton
    case playButton
    case skipButton
    case skipHint
    case greatJob
    case allTasksCompleted
    case backToList
    case taskListSheetTitle
    case taskListSheetCountFormat
    case minutesPerTaskFormat
    case adPlaceholder
    case taskNameLengthWarningFormat
    case taskEditDiscardChangesTitle
    case taskEditDiscardChangesMessage
    case taskEditDiscardChangesButton
    case taskEditSaveChangesButton
}

enum AppLocalization {
    static func text(for key: AppText, language: AppLanguage, arguments: [CVarArg] = []) -> String {
        let template = translations[language]?[key] ?? translations[.english]?[key] ?? key.rawValue
        guard !arguments.isEmpty else {
            return template
        }
        return String(format: template, locale: language.locale, arguments: arguments)
    }

    private static let translations: [AppLanguage: [AppText: String]] = [
        .japanese: [
            .appName: "FitTasks",
            .splashCaption: "今日もひとつずつ片づけよう",
            .welcomeMessage: "言語を選択してください",
            .changeLaterHint: "この設定はあとから設定画面で変更できます。",
            .languageJapanese: "日本語",
            .languageEnglish: "English",
            .languageChinese: "中文",
            .languageKorean: "한국어",
            .noTasksTitle: "まだタスクがありません",
            .noTasksDescription: "所要時間とやることを登録すると、1タスクごとの持ち時間を自動で割り振ります。",
            .noTasksPrompt: "さっそく新しいタスクを追加しましょう。",
            .createFirstTask: "最初のタスクを作成",
            .addTaskTitle: "タスクを追加",
            .editTaskTitle: "タスクを編集",
            .timeSettings: "時間設定",
            .startTime: "開始時刻",
            .endTime: "終了時刻",
            .durationLabel: "所要時間（分）",
            .totalDurationFormat: "合計 %d 分",
            .addTaskSection: "タスク追加",
            .taskNameLabel: "タスク名",
            .taskWeightLabel: "重要度",
            .taskColorLabel: "カラー",
            .totalTasksLabel: "タスク数",
            .totalTaskCardsLabel: "タスクグループ数",
            .addButton: "追加",
            .taskListCountFormat: "登録済みタスク %d 件",
            .saveButton: "保存",
            .backButton: "戻る",
            .closeButton: "閉じる",
            .cancelButton: "キャンセル",
            .okButton: "OK",
            .selectTimeTitle: "時刻を選択",
            .taskGroupMissingTitle: "編集対象が見つかりません",
            .taskGroupMissingMessage: "対象のタスクグループが削除された可能性があります。",
            .deleteTaskGroupConfirmTitle: "このタスクグループを削除しますか？",
            .deleteButton: "削除",
            .editButton: "編集",
            .settingsTitle: "設定",
            .currentLanguage: "言語",
            .themeSetting: "テーマ",
            .themeSystem: "システム",
            .themeLight: "ライト",
            .themeDark: "ダーク",
            .timerTitle: "タイマー",
            .nextTasks: "次のタスク",
            .openTaskListSheet: "一覧を拡大",
            .timerExitConfirmTitle: "タイマーを閉じますか？",
            .timerExitConfirmMessage: "計測中に戻ると、タイマーは終了します。",
            .timerExitConfirmButton: "タイマーを閉じる",
            .pauseButton: "一時停止",
            .playButton: "再開",
            .skipButton: "スキップ",
            .skipHint: "スキップは長押しです",
            .greatJob: "おつかれさま",
            .allTasksCompleted: "すべてのタスクが完了しました",
            .backToList: "一覧へ戻る",
            .taskListSheetTitle: "タスク一覧",
            .taskListSheetCountFormat: "%d 件のタスク",
            .minutesPerTaskFormat: "平均 %d 分",
            .adPlaceholder: "AdMob バナー表示エリア",
            .taskNameLengthWarningFormat: "タスク名は %d 文字までです",
            .taskEditDiscardChangesTitle: "保存していない変更があります",
            .taskEditDiscardChangesMessage: "このまま戻ると、追加・編集した内容は保存されません。",
            .taskEditDiscardChangesButton: "編集を破棄",
            .taskEditSaveChangesButton: "保存する"
        ],
        .english: [
            .appName: "FitTasks",
            .splashCaption: "One task at a time, today.",
            .welcomeMessage: "Choose your language",
            .changeLaterHint: "You can change this later from Settings.",
            .languageJapanese: "Japanese",
            .languageEnglish: "English",
            .languageChinese: "Chinese",
            .languageKorean: "Korean",
            .noTasksTitle: "No task groups yet",
            .noTasksDescription: "Add a time range and tasks, and FitTasks will split the available time for you.",
            .noTasksPrompt: "Create a new task group to get started.",
            .createFirstTask: "Create your first task",
            .addTaskTitle: "Add Task Group",
            .editTaskTitle: "Edit Task Group",
            .timeSettings: "Time Settings",
            .startTime: "Start",
            .endTime: "End",
            .durationLabel: "Duration (min)",
            .totalDurationFormat: "Total %d min",
            .addTaskSection: "Add Task",
            .taskNameLabel: "Task name",
            .taskWeightLabel: "Priority",
            .taskColorLabel: "Color",
            .totalTasksLabel: "Tasks",
            .totalTaskCardsLabel: "Task groups",
            .addButton: "Add",
            .taskListCountFormat: "%d tasks",
            .saveButton: "Save",
            .backButton: "Back",
            .closeButton: "Close",
            .cancelButton: "Cancel",
            .okButton: "OK",
            .selectTimeTitle: "Select time",
            .taskGroupMissingTitle: "Task group not found",
            .taskGroupMissingMessage: "The selected task group may have been removed.",
            .deleteTaskGroupConfirmTitle: "Delete this task group?",
            .deleteButton: "Delete",
            .editButton: "Edit",
            .settingsTitle: "Settings",
            .currentLanguage: "Language",
            .themeSetting: "Theme",
            .themeSystem: "System",
            .themeLight: "Light",
            .themeDark: "Dark",
            .timerTitle: "Timer",
            .nextTasks: "Next tasks",
            .openTaskListSheet: "Expand list",
            .timerExitConfirmTitle: "Leave timer?",
            .timerExitConfirmMessage: "Leaving this screen stops the current timer session view.",
            .timerExitConfirmButton: "Leave",
            .pauseButton: "Pause",
            .playButton: "Play",
            .skipButton: "Skip",
            .skipHint: "Long press to skip",
            .greatJob: "Great job",
            .allTasksCompleted: "All tasks are complete",
            .backToList: "Back to list",
            .taskListSheetTitle: "Task list",
            .taskListSheetCountFormat: "%d tasks",
            .minutesPerTaskFormat: "Avg %d min",
            .adPlaceholder: "AdMob banner area",
            .taskNameLengthWarningFormat: "Task names can be up to %d characters",
            .taskEditDiscardChangesTitle: "You have unsaved changes",
            .taskEditDiscardChangesMessage: "If you go back now, your added or edited content will be lost.",
            .taskEditDiscardChangesButton: "Discard edits",
            .taskEditSaveChangesButton: "Save"
        ],
        .chineseSimplified: [
            .appName: "FitTasks",
            .splashCaption: "今天也一次完成一个任务",
            .welcomeMessage: "请选择语言",
            .changeLaterHint: "之后也可以在设置中修改。",
            .languageJapanese: "日语",
            .languageEnglish: "英语",
            .languageChinese: "中文",
            .languageKorean: "韩语",
            .noTasksTitle: "还没有任务组",
            .noTasksDescription: "添加时间范围和任务后，FitTasks 会自动为每个任务分配时间。",
            .noTasksPrompt: "马上新建一个任务组开始吧。",
            .createFirstTask: "创建第一个任务",
            .addTaskTitle: "添加任务组",
            .editTaskTitle: "编辑任务组",
            .timeSettings: "时间设置",
            .startTime: "开始时间",
            .endTime: "结束时间",
            .durationLabel: "时长（分钟）",
            .totalDurationFormat: "总计 %d 分钟",
            .addTaskSection: "添加任务",
            .taskNameLabel: "任务名称",
            .taskWeightLabel: "重要度",
            .taskColorLabel: "颜色",
            .totalTasksLabel: "任务数",
            .totalTaskCardsLabel: "任务组数",
            .addButton: "添加",
            .taskListCountFormat: "已添加 %d 个任务",
            .saveButton: "保存",
            .backButton: "返回",
            .closeButton: "关闭",
            .cancelButton: "取消",
            .okButton: "确定",
            .selectTimeTitle: "选择时间",
            .taskGroupMissingTitle: "未找到任务组",
            .taskGroupMissingMessage: "该任务组可能已经被删除。",
            .deleteTaskGroupConfirmTitle: "要删除这个任务组吗？",
            .deleteButton: "删除",
            .editButton: "编辑",
            .settingsTitle: "设置",
            .currentLanguage: "语言",
            .themeSetting: "主题",
            .themeSystem: "跟随系统",
            .themeLight: "浅色",
            .themeDark: "深色",
            .timerTitle: "计时器",
            .nextTasks: "接下来的任务",
            .openTaskListSheet: "展开列表",
            .timerExitConfirmTitle: "离开计时器？",
            .timerExitConfirmMessage: "离开后将结束当前计时界面的会话显示。",
            .timerExitConfirmButton: "离开",
            .pauseButton: "暂停",
            .playButton: "继续",
            .skipButton: "跳过",
            .skipHint: "长按才会跳过",
            .greatJob: "做得很好",
            .allTasksCompleted: "所有任务已完成",
            .backToList: "返回列表",
            .taskListSheetTitle: "任务列表",
            .taskListSheetCountFormat: "%d 个任务",
            .minutesPerTaskFormat: "平均 %d 分钟",
            .adPlaceholder: "AdMob 横幅区域",
            .taskNameLengthWarningFormat: "任务名最多 %d 个字符",
            .taskEditDiscardChangesTitle: "有尚未保存的更改",
            .taskEditDiscardChangesMessage: "如果现在返回，刚刚新增或编辑的内容将不会保存。",
            .taskEditDiscardChangesButton: "放弃编辑",
            .taskEditSaveChangesButton: "保存"
        ],
        .korean: [
            .appName: "FitTasks",
            .splashCaption: "오늘도 하나씩 해내봐요",
            .welcomeMessage: "언어를 선택하세요",
            .changeLaterHint: "이 설정은 나중에 설정 화면에서 변경할 수 있습니다.",
            .languageJapanese: "일본어",
            .languageEnglish: "영어",
            .languageChinese: "중국어",
            .languageKorean: "한국어",
            .noTasksTitle: "아직 작업 그룹이 없습니다",
            .noTasksDescription: "시간 범위와 할 일을 추가하면 FitTasks가 작업별 시간을 자동으로 나눠 줍니다.",
            .noTasksPrompt: "바로 새 작업 그룹을 추가해 보세요.",
            .createFirstTask: "첫 작업 만들기",
            .addTaskTitle: "작업 그룹 추가",
            .editTaskTitle: "작업 그룹 편집",
            .timeSettings: "시간 설정",
            .startTime: "시작",
            .endTime: "종료",
            .durationLabel: "소요 시간(분)",
            .totalDurationFormat: "총 %d분",
            .addTaskSection: "작업 추가",
            .taskNameLabel: "작업 이름",
            .taskWeightLabel: "중요도",
            .taskColorLabel: "색상",
            .totalTasksLabel: "작업 수",
            .totalTaskCardsLabel: "작업 그룹 수",
            .addButton: "추가",
            .taskListCountFormat: "등록된 작업 %d개",
            .saveButton: "저장",
            .backButton: "뒤로",
            .closeButton: "닫기",
            .cancelButton: "취소",
            .okButton: "확인",
            .selectTimeTitle: "시간 선택",
            .taskGroupMissingTitle: "작업 그룹을 찾을 수 없습니다",
            .taskGroupMissingMessage: "선택한 작업 그룹이 삭제되었을 수 있습니다.",
            .deleteTaskGroupConfirmTitle: "이 작업 그룹을 삭제할까요?",
            .deleteButton: "삭제",
            .editButton: "편집",
            .settingsTitle: "설정",
            .currentLanguage: "언어",
            .themeSetting: "테마",
            .themeSystem: "시스템",
            .themeLight: "라이트",
            .themeDark: "다크",
            .timerTitle: "타이머",
            .nextTasks: "다음 작업",
            .openTaskListSheet: "목록 확대",
            .timerExitConfirmTitle: "타이머를 닫을까요?",
            .timerExitConfirmMessage: "이 화면을 나가면 현재 타이머 세션 표시가 종료됩니다.",
            .timerExitConfirmButton: "닫기",
            .pauseButton: "일시정지",
            .playButton: "재생",
            .skipButton: "건너뛰기",
            .skipHint: "길게 눌러야 건너뜁니다",
            .greatJob: "수고했어요",
            .allTasksCompleted: "모든 작업이 완료되었습니다",
            .backToList: "목록으로 돌아가기",
            .taskListSheetTitle: "작업 목록",
            .taskListSheetCountFormat: "%d개 작업",
            .minutesPerTaskFormat: "평균 %d분",
            .adPlaceholder: "AdMob 배너 영역",
            .taskNameLengthWarningFormat: "작업 이름은 최대 %d자입니다",
            .taskEditDiscardChangesTitle: "저장하지 않은 변경 사항이 있습니다",
            .taskEditDiscardChangesMessage: "지금 돌아가면 방금 추가하거나 수정한 내용이 저장되지 않습니다.",
            .taskEditDiscardChangesButton: "편집 폐기",
            .taskEditSaveChangesButton: "저장하기"
        ]
    ]
}
