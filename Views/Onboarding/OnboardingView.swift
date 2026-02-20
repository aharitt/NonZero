import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(version).\(build)"
    }

    private let features: [(icon: String, color: Color, title: String, description: String)] = [
        ("checkmark.circle.fill", .green, "Track Your Way", "Boolean, count, or timed tasks — whatever fits your habit"),
        ("flame.fill", .orange, "Build Momentum", "Stay consistent day by day and build momentum"),
        ("chart.bar.fill", .blue, "See Your Progress", "Stats, heatmaps, and comeback tracking at a glance"),
        ("heart.fill", .pink, "Stay Connected", "Sync with HealthKit and the Fitness app automatically")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                Text("NonZero")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Make every day count")
                    .font(.title3)
                    .foregroundColor(.secondary)

                Text(appVersion)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 32)

            VStack(spacing: 12) {
                ForEach(features, id: \.title) { feature in
                    HStack(spacing: 14) {
                        Image(systemName: feature.icon)
                            .font(.title2)
                            .foregroundColor(feature.color)
                            .frame(width: 36)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(feature.title)
                                .font(.body)
                                .fontWeight(.semibold)

                            Text(feature.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemGroupedBackground))
                    )
                }
            }
            .padding(.horizontal)

            Spacer()

            Button {
                onComplete()
            } label: {
                Text("Get Started")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .controlSize(.large)
            .buttonBorderShape(.capsule)
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
