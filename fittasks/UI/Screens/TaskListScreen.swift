import SwiftUI

struct TaskListScreen: View {
    @EnvironmentObject private var store: AppStore

    @State private var pendingDeleteGroup: TaskGroup?

    private var totalTaskCount: Int {
        store.taskGroups.reduce(0) { partialResult, group in
            partialResult + group.tasks.count
        }
    }

    private var taskCardCount: Int {
        store.taskGroups.count
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    heroCard

                    if store.taskGroups.isEmpty {
                        emptyState
                    } else {
                        LazyVGrid(
                            columns: [
                                GridItem(
                                    .adaptive(minimum: min(max(proxy.size.width * 0.42, 280), 380), maximum: 420),
                                    spacing: 16
                                )
                            ],
                            spacing: 16
                        ) {
                            ForEach(store.taskGroups) { group in
                                TaskGroupCard(
                                    group: group,
                                    onStart: { store.navigationPath.append(.timer(group.id)) },
                                    onEdit: { store.navigationPath.append(.taskEdit(group.id)) },
                                    onDelete: { pendingDeleteGroup = group }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 108)
            }
            .scrollIndicators(.hidden)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    FooterBannerAd()
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                }
                .padding(.bottom, 10)
                .background(.clear)
            }
            .overlay(alignment: .bottomTrailing) {
                addButton
                    .padding(.trailing, 20)
                    .padding(.bottom, 88)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.navigationPath.append(.settings)
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .alert(
                store.text(.deleteTaskGroupConfirmTitle),
                isPresented: Binding(
                    get: { pendingDeleteGroup != nil },
                    set: { if !$0 { pendingDeleteGroup = nil } }
                ),
                presenting: pendingDeleteGroup
            ) { group in
                Button(store.text(.cancelButton), role: .cancel) {
                    pendingDeleteGroup = nil
                }
                Button(store.text(.deleteButton), role: .destructive) {
                    store.deleteTaskGroup(group)
                    pendingDeleteGroup = nil
                }
            }
        }
    }

    private var heroCard: some View {
        GlassCard {
            VStack(spacing: 14) {
                // Keep the onboarding explanation and CTA together in the hero card for every locale.
                VStack(spacing: 8) {
                    Text(store.text(.noTasksDescription))
                        .font(FitTasksTypography.font(.body))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                }

                ViewThatFits {
                    HStack(spacing: 12) {
                        summaryMetric(title: store.text(.totalTasksLabel), value: "\(totalTaskCount)")
                        summaryMetric(title: store.text(.totalTaskCardsLabel), value: "\(taskCardCount)")
                    }
                    VStack(spacing: 10) {
                        summaryMetric(title: store.text(.totalTasksLabel), value: "\(totalTaskCount)")
                        summaryMetric(title: store.text(.totalTaskCardsLabel), value: "\(taskCardCount)")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    private var emptyState: some View {
        GlassCard {
            VStack(spacing: 16) {
                Text(store.text(.noTasksTitle))
                    .font(FitTasksTypography.font(.title3, weight: .bold))

                Button(store.text(.createFirstTask)) {
                    store.navigationPath.append(.taskEdit(nil))
                }
                .buttonStyle(.borderedProminent)
                .tint(FitTasksStyle.primaryAccent)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }

    private var addButton: some View {
        Button {
            store.navigationPath.append(.taskEdit(nil))
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(
                    LinearGradient(
                        colors: [FitTasksStyle.primaryAccent, FitTasksStyle.secondaryAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: Circle()
                )
                .shadow(color: FitTasksStyle.primaryAccent.opacity(0.28), radius: 18, x: 0, y: 12)
        }
        .buttonStyle(.plain)
    }

    private func summaryPill(text: String) -> some View {
        Text(text)
            .font(FitTasksTypography.font(.caption, weight: .semibold))
            .foregroundStyle(FitTasksStyle.primaryAccent)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.66), in: Capsule())
    }

    private func summaryMetric(title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(FitTasksTypography.font(.caption, weight: .semibold))
                .foregroundStyle(.secondary)
            summaryPill(text: value)
        }
    }
}
