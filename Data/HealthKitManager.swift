import Foundation
import HealthKit
import Combine

@MainActor
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false

    // Common workout types users might track
    let availableWorkoutTypes: [(name: String, type: HKWorkoutActivityType)] = [
        ("Running", .running),
        ("Walking", .walking),
        ("Cycling", .cycling),
        ("Swimming", .swimming),
        ("Yoga", .yoga),
        ("Strength Training", .traditionalStrengthTraining),
        ("HIIT", .highIntensityIntervalTraining),
        ("Hiking", .hiking),
        ("Elliptical", .elliptical),
        ("Rowing", .rowing),
        ("Stairs", .stairClimbing),
        ("Functional Training", .functionalStrengthTraining),
        ("Cross Training", .crossTraining),
        ("Other", .other)
    ]

    private init() {}

    // Check if HealthKit is available on this device
    var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    // Request authorization to read workout data
    func requestAuthorization() async throws {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }

        let workoutType = HKObjectType.workoutType()

        try await healthStore.requestAuthorization(toShare: [], read: [workoutType])

        let status = healthStore.authorizationStatus(for: workoutType)
        isAuthorized = (status == .sharingAuthorized)
    }

    // Fetch total workout time for a specific date and workout type
    func fetchWorkoutMinutes(for date: Date, workoutType: HKWorkoutActivityType?) async throws -> Double {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: []
        )

        let workoutPredicate: NSPredicate
        if let workoutType = workoutType {
            workoutPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                predicate,
                HKQuery.predicateForWorkouts(with: workoutType)
            ])
        } else {
            workoutPredicate = predicate
        }

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: workoutPredicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    print("🏃 HealthKit query error: \(error)")
                    continuation.resume(throwing: error)
                    return
                }

                guard let workouts = samples as? [HKWorkout] else {
                    print("🏃 No workouts found (samples is nil or wrong type)")
                    continuation.resume(returning: 0.0)
                    return
                }

                print("🏃 Found \(workouts.count) workout(s) for date range \(startOfDay) to \(endOfDay)")
                for workout in workouts {
                    let durationMin = workout.duration / 60.0
                    print("🏃   - Type: \(workout.workoutActivityType.rawValue), Duration: \(durationMin) min, Start: \(workout.startDate)")
                }

                let totalMinutes = workouts.reduce(0.0) { total, workout in
                    total + workout.duration / 60.0 // Convert seconds to minutes
                }

                print("🏃 Total minutes: \(totalMinutes)")
                continuation.resume(returning: totalMinutes)
            }

            healthStore.execute(query)
        }
    }

    // Get workout type from string name
    func workoutType(from name: String?) -> HKWorkoutActivityType? {
        guard let name = name else { return nil }
        return availableWorkoutTypes.first { $0.name == name }?.type
    }

    // Get name from workout type
    func workoutName(from type: HKWorkoutActivityType) -> String? {
        return availableWorkoutTypes.first { $0.type == type }?.name
    }
}

enum HealthKitError: LocalizedError {
    case notAvailable
    case notAuthorized
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .notAuthorized:
            return "HealthKit access not authorized"
        case .fetchFailed:
            return "Failed to fetch workout data"
        }
    }
}
