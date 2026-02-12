import SwiftUI

struct IconPicker: View {
    @Binding var selectedIcon: String?
    @Environment(\.dismiss) private var dismiss

    // Common SF Symbols for tasks
    let icons = [
        "star.fill", "heart.fill", "flame.fill", "bolt.fill",
        "book.fill", "pencil", "paintbrush.fill", "hammer.fill",
        "dumbbell.fill", "figure.walk", "bicycle", "leaf.fill",
        "cup.and.saucer.fill", "fork.knife", "carrot.fill", "apple.logo",
        "moon.stars.fill", "sun.max.fill", "cloud.fill", "drop.fill",
        "music.note", "headphones", "phone.fill", "envelope.fill",
        "briefcase.fill", "laptopcomputer", "camera.fill", "cart.fill",
        "gift.fill", "gamecontroller.fill", "ticket.fill", "trophy.fill"
    ]

    let columns = [
        GridItem(.adaptive(minimum: 60))
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    // None option
                    Button {
                        selectedIcon = nil
                        dismiss()
                    } label: {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(selectedIcon == nil ? Color.blue.opacity(0.2) : Color(.systemGray6))
                                    .frame(width: 60, height: 60)

                                Image(systemName: "xmark")
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == nil ? .blue : .secondary)
                            }
                            Text("None")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)

                    // Icon options
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                            dismiss()
                        } label: {
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(selectedIcon == icon ? Color.blue.opacity(0.2) : Color(.systemGray6))
                                        .frame(width: 60, height: 60)

                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(selectedIcon == icon ? .blue : .primary)
                                }
                                Text(icon.split(separator: ".").first.map(String.init) ?? icon)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    IconPicker(selectedIcon: .constant("star.fill"))
}
