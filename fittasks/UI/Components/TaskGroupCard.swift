import SwiftUI

struct TaskGroupCard: View {
    @EnvironmentObject private var store: AppStore

    let group: TaskGroup
    let onStart: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        GlassCard {
            ViewThatFits {
                wideLayout
                compactLayout
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onStart)
    }

    private var wideLayout: some View {
        HStack(alignment: .top, spacing: 18) {
            timeColumn
                .frame(width: 86)

            VStack(alignment: .leading, spacing: 10) {
                durationBadge
                taskPills
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            actionColumn
        }
    }

    private var compactLayout: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 12) {
                    timeColumn
                    durationBadge
                }
                .frame(width: 96, alignment: .leading)

                taskPills
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            actionRow
        }
    }

    private var timeColumn: some View {
        VStack(spacing: 10) {
            timeBadge(group.startTime.label)

            Capsule()
                .fill(FitTasksStyle.primaryAccent.opacity(0.2))
                .frame(width: 2, height: 26)

            timeBadge(group.endTime.label)
        }
    }

    private var durationBadge: some View {
        Text(store.text(.minutesPerTaskFormat, group.durationPerTaskMinutes))
            .font(FitTasksTypography.font(.caption, weight: .semibold))
            .foregroundStyle(FitTasksStyle.primaryAccent)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(FitTasksStyle.primaryAccent.opacity(0.1), in: Capsule())
    }

    private var taskPills: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(group.tasks.enumerated()), id: \.element.id) { index, task in
                HStack(spacing: 10) {
                    Text(task.title)
                        .font(FitTasksTypography.font(.subheadline, weight: .semibold))
                        .lineLimit(1)
                        .foregroundStyle(task.palette.color.accessibleForeground)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 3) {
                        ForEach(0..<task.safeWeight, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(task.palette.color.accessibleForeground)
                        }
                    }

                    Text(formatTaskDuration(group.durationForTask(at: index)))
                        .font(.caption.monospacedDigit().weight(.bold))
                        .foregroundStyle(task.palette.color.accessibleForeground)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(task.palette.color, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }

    private var actionColumn: some View {
        VStack(spacing: 10) {
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.red.opacity(0.8))
                    .frame(width: 38, height: 38)
                    .background(Color.red.opacity(0.08), in: Circle())
            }
            .buttonStyle(.plain)

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(FitTasksStyle.primaryAccent)
                    .frame(width: 38, height: 38)
                    .background(FitTasksStyle.primaryAccent.opacity(0.08), in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var actionRow: some View {
        HStack(spacing: 10) {
            Spacer(minLength: 0)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.red.opacity(0.8))
                    .frame(width: 38, height: 38)
                    .background(Color.red.opacity(0.08), in: Circle())
            }
            .buttonStyle(.plain)

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(FitTasksStyle.primaryAccent)
                    .frame(width: 38, height: 38)
                    .background(FitTasksStyle.primaryAccent.opacity(0.08), in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private func timeBadge(_ label: String) -> some View {
        Text(label)
            .font(.subheadline.monospacedDigit().weight(.bold))
            .foregroundStyle(.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
