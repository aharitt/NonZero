import SwiftData
import Foundation

/*
 Schema Versioning Guide
 =======================

 This file manages database schema versions and migrations for the NonZero app.

 How to add a new schema version:

 1. Create a new schema enum (e.g., TaskSchemaV3):
    enum TaskSchemaV3: VersionedSchema {
        static var versionIdentifier = Schema.Version(3, 0, 0)
        static var models: [any PersistentModel.Type] {
            [Task.self, Entry.self]
        }

        @Model
        final class Task {
            // Add your new properties here
        }

        @Model
        final class Entry {
            // Copy from previous version
        }
    }

 2. Add the new schema to TaskMigrationPlan.schemas array:
    static var schemas: [any VersionedSchema.Type] {
        [TaskSchemaV1.self, TaskSchemaV2.self, TaskSchemaV3.self]
    }

 3. Add a migration stage:
    - For simple changes (adding properties with defaults, renaming), use .lightweight
    - For complex changes (data transformation), use .custom

    static let migrateV2toV3 = MigrationStage.lightweight(
        fromVersion: TaskSchemaV2.self,
        toVersion: TaskSchemaV3.self
    )

 4. Add the migration to the stages array:
    static var stages: [MigrationStage] {
        [migrateV1toV2, migrateV2toV3]
    }

 5. Update NonZeroApp.swift to use the new schema version:
    let modelConfiguration = ModelConfiguration(schema: TaskSchemaV3.self, ...)

 Migration will happen automatically when users update the app.
 Existing data will be preserved and transformed according to the migration stages.
 */

// MARK: - Schema Version 1 (Original)
enum TaskSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Task.self, Entry.self]
    }

    @Model
    final class Task {
        var id: UUID
        var name: String
        var taskType: TaskType
        var minimumValue: Double
        var goalValue: Double?
        var unit: String?
        var healthKitWorkoutType: String?
        var icon: String?
        var createdAt: Date
        var isArchived: Bool
        var sortOrder: Int

        @Relationship(deleteRule: .cascade, inverse: \Entry.task)
        var entries: [Entry] = []

        init(
            id: UUID = UUID(),
            name: String,
            taskType: TaskType,
            minimumValue: Double,
            goalValue: Double? = nil,
            unit: String? = nil,
            healthKitWorkoutType: String? = nil,
            icon: String? = nil,
            createdAt: Date = Date(),
            isArchived: Bool = false,
            sortOrder: Int = 0
        ) {
            self.id = id
            self.name = name
            self.taskType = taskType
            self.minimumValue = minimumValue
            self.goalValue = goalValue
            self.unit = unit
            self.healthKitWorkoutType = healthKitWorkoutType
            self.icon = icon
            self.createdAt = createdAt
            self.isArchived = isArchived
            self.sortOrder = sortOrder
        }
    }

    @Model
    final class Entry {
        var id: UUID
        var date: Date
        var value: Double
        var note: String?
        var createdAt: Date

        var task: Task?

        init(
            id: UUID = UUID(),
            task: Task,
            date: Date,
            value: Double,
            note: String? = nil,
            createdAt: Date = Date()
        ) {
            self.id = id
            self.task = task
            self.date = date
            self.value = value
            self.note = note
            self.createdAt = createdAt
        }
    }
}

// MARK: - Schema Version 2 (With PushFit Pro Support)
enum TaskSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Task.self, Entry.self]
    }

    @Model
    final class Task {
        var id: UUID
        var name: String
        var taskType: TaskType
        var minimumValue: Double
        var goalValue: Double?
        var unit: String?
        var healthKitWorkoutType: String?
        var pushFitProEnabled: Bool // NEW: PushFit Pro integration
        var icon: String?
        var createdAt: Date
        var isArchived: Bool
        var sortOrder: Int

        @Relationship(deleteRule: .cascade, inverse: \Entry.task)
        var entries: [Entry] = []

        init(
            id: UUID = UUID(),
            name: String,
            taskType: TaskType,
            minimumValue: Double,
            goalValue: Double? = nil,
            unit: String? = nil,
            healthKitWorkoutType: String? = nil,
            pushFitProEnabled: Bool = false,
            icon: String? = nil,
            createdAt: Date = Date(),
            isArchived: Bool = false,
            sortOrder: Int = 0
        ) {
            self.id = id
            self.name = name
            self.taskType = taskType
            self.minimumValue = minimumValue
            self.goalValue = goalValue
            self.unit = unit
            self.healthKitWorkoutType = healthKitWorkoutType
            self.pushFitProEnabled = pushFitProEnabled
            self.icon = icon
            self.createdAt = createdAt
            self.isArchived = isArchived
            self.sortOrder = sortOrder
        }
    }

    @Model
    final class Entry {
        var id: UUID
        var date: Date
        var value: Double
        var note: String?
        var createdAt: Date

        var task: Task?

        init(
            id: UUID = UUID(),
            task: Task,
            date: Date,
            value: Double,
            note: String? = nil,
            createdAt: Date = Date()
        ) {
            self.id = id
            self.task = task
            self.date = date
            self.value = value
            self.note = note
            self.createdAt = createdAt
        }
    }
}

// MARK: - Migration Plan
enum TaskMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TaskSchemaV1.self, TaskSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    // Lightweight migration from V1 to V2
    // SwiftData will automatically set pushFitProEnabled = false for existing tasks
    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: TaskSchemaV1.self,
        toVersion: TaskSchemaV2.self
    )
}
