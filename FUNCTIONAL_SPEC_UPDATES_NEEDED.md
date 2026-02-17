# FUNCTIONAL_SPEC.md Update Checklist

## Changes Needed to Reflect Current Implementation

### 1. Task Types (Section 6)
- [ ] Merge "Duration" and "Timer" into single "Time" type
- [ ] Update TaskType enum to show: `.boolean`, `.count`, `.time`
- [ ] Explain that Time tasks support both manual entry and timer functionality

### 2. Settings Tab (Section 4.4, Lines 168-178)
**Add:**
- [ ] Sounds toggle: "Play sound when marking tasks"
- [ ] Export Tasks button: "Save task definitions to file"
- [ ] Import Tasks button: "Load task definitions from file"
- [ ] Reset All Records button: "Delete all entries but keep task definitions"

**Remove:**
- [ ] "HealthKit permissions management" (not in Settings tab)
- [ ] "About and help sections" (not implemented)

**Update:**
- [ ] Move "Data export options" from "(future)" to implemented

### 3. Stats Detail View (Section 4.3, Lines 149-162)
**Update:**
- [ ] Remove description of TaskInfoCard (task type, min/goal, streak display)
- [ ] Add: "Task name with type icon shown in navigation bar (inline style, .headline font)"
- [ ] Add: "Detail view starts directly with Statistics section"
- [ ] Update: Calendar heatmap shows "60 days" not "30 days"
- [ ] Update: Heatmap calendar cells are long-pressable to edit past entries

### 4. Features Section (Section 5)
**Add new 5.6: Data Export/Import**
```markdown
### 5.6 Data Export/Import

**Purpose**: Backup and restore task definitions during major updates

**Export**:
- Exports all task definitions (including archived tasks)
- JSON format with timestamp
- File name: `NonZero_Tasks_YYYY-MM-dd_HHmmss.json`
- Includes: name, type, min/goal, unit, integrations, icon, createdAt
- Uses iOS share sheet for saving/sharing

**Import**:
- Reads JSON file via file picker
- Creates new tasks with all original properties
- Shows success/error alert with count
- Validates task type before creation

**Location**: Settings → Data section
```

### 5. Future Enhancements (Section 10.1, Lines 567-571)
**Remove from Phase 2:**
- [ ] "Export to CSV/JSON" - Already implemented!
- [ ] "Import data" - Already implemented!

**Keep:**
- [ ] "Edit past entries" - Partially implemented via heatmap long-press

### 6. Add Missing Features
**Section 5.7: Live Activities (Implemented but Disabled)**
```markdown
### 5.7 Live Activities

**Purpose**: Display running timer on lock screen

**Features**:
- Shows timer on lock screen when active
- Dynamic Island support (iPhone 14 Pro+)
- Custom elapsed time formatting (M:SS or H:MM:SS)
- Simplified version to reduce memory usage

**Status**:
- Code fully implemented
- Requires paid Apple Developer account ($99/year)
- Currently disabled for free account users

**Future**: Will be enabled when user upgrades to paid developer account
```

### 7. Settings Features Detail
**Update Section 4.4 to include:**
```markdown
### 4.4 Settings Tab

**Features**:

**General Section**:
- Badge toggle: Show/hide count of incomplete tasks on app icon
- Sounds toggle: Play sound when marking tasks complete

**Data Section**:
- Export Tasks: Save all task definitions to JSON file
- Import Tasks: Load task definitions from JSON file
- Reset All Records: Delete all logged entries (keeps task definitions)
  - Confirmation dialog required
  - Irreversible action warning

**About Section**:
- App version and build number display
```

### 8. Technical Details to Update

**Section 8.1: HealthKit (Lines 418-442)**
- [ ] Update line 441: Change "strictStartDate" to "no options (overlapping workouts included)"
- [ ] Add note: "Query predicate uses `options: []` to include any workout overlapping with the target date"

**Section 7.1: Data Model**
- [ ] Remove TaskType `.duration` and `.timer`
- [ ] Add TaskType `.time` (replaces both)
- [ ] Clarify that `.time` tasks support both manual entry and timer functionality

### 9. App Badge Behavior
**Clarify Section 5.5 (Line 268):**
- Current: "Shows count of incomplete tasks for current day"
- Settings says: "Display count of zero tasks on app icon"
- **Determine**: Are these the same? Update wording to be consistent

### 10. Version History (Appendix C)
**Add Version 1.2 entry:**
```markdown
| 1.2 | 2026-02-14 | - Added Export/Import task definitions<br>- Implemented Live Activities (disabled for free accounts)<br>- Fixed HealthKit query predicate bug<br>- Simplified Stats detail view (removed redundant info card)<br>- Added Sounds toggle in Settings |
```

### 11. Project Structure (Section 9.4)
**Add to Data/ folder:**
```
├── Data/
│   ├── DataStore.swift
│   ├── SeedData.swift
│   ├── Formatting.swift
│   ├── HealthKitManager.swift       # Add this
│   ├── TimerManager.swift           # Add this
│   ├── SettingsManager.swift        # Add this
│   ├── AppBadgeManager.swift        # Add this
│   └── TimerActivityAttributes.swift # Add this
```

**Add new folder:**
```
├── Widgets/                          # NEW
│   ├── NonZeroWidgets.swift
│   ├── TimerLiveActivity_Simple.swift
│   └── QUICK_SETUP_CHECKLIST.md
```

---

## Summary of Major Changes

1. ✅ **Implemented**: Export/Import task definitions
2. ✅ **Implemented**: Live Activities (code ready, disabled for free accounts)
3. ✅ **Implemented**: Sounds toggle in Settings
4. ✅ **Fixed**: HealthKit query predicate bug
5. ✅ **Simplified**: Stats detail view (removed TaskInfoCard)
6. ❌ **Not implemented**: About/Help sections
7. ❌ **Not implemented**: HealthKit permission management in Settings
8. 📝 **Clarification needed**: Task type consolidation (3 types vs 4 in spec)
9. 📝 **Clarification needed**: Badge behavior description inconsistency

---

**Next Steps:**
1. Review this checklist
2. Decide on Task Type naming (keep "Time" or split back to "Duration" and "Timer")
3. Update FUNCTIONAL_SPEC.md with all changes
4. Bump version to 1.2
5. Update "Last Updated" date
