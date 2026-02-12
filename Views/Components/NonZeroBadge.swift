import SwiftUI

struct NonZeroBadge: View {
    let isNonZero: Bool
    let size: CGFloat

    init(isNonZero: Bool, size: CGFloat = 30) {
        self.isNonZero = isNonZero
        self.size = size
    }

    var body: some View {
        Circle()
            .fill(isNonZero ? Color.green : Color.gray.opacity(0.3))
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: isNonZero ? "checkmark" : "xmark")
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundColor(.white)
            )
    }
}

struct StreakBadge: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
            Text("\(streak)")
                .font(.headline)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
}

struct TaskTypeIcon: View {
    let taskType: TaskType
    let size: CGFloat

    init(taskType: TaskType, size: CGFloat = 20) {
        self.taskType = taskType
        self.size = size
    }

    var iconName: String {
        switch taskType {
        case .boolean:
            return "checkmark.circle"
        case .count:
            return "number.circle"
        case .duration:
            return "clock"
        case .timer:
            return "timer"
        }
    }

    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: size))
            .foregroundColor(.secondary)
    }
}

#Preview {
    VStack(spacing: 20) {
        NonZeroBadge(isNonZero: true)
        NonZeroBadge(isNonZero: false)
        StreakBadge(streak: 7)
        HStack {
            TaskTypeIcon(taskType: .boolean)
            TaskTypeIcon(taskType: .count)
            TaskTypeIcon(taskType: .duration)
            TaskTypeIcon(taskType: .timer)
        }
    }
    .padding()
}
