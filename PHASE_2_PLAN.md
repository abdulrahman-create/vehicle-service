# Vehicle Service Tracker - Phase 2 Development Plan

## Overview
Phase 2 focuses on enhancing user experience with advanced features including notifications, photo attachments, customization options, and maintenance templates.

---

## Feature 1: Push Notifications for Reminders

### Objectives
- Send local notifications for upcoming service reminders
- Alert users for overdue services
- Scheduled notifications based on date and odometer

### Technical Implementation
**Dependencies:**
- `flutter_local_notifications: ^17.0.0` - Local notification handling
- `permission_handler: ^11.0.0` - Notification permission management
- `timezone: ^0.9.0` - Schedule notifications at specific times

**Files to Create:**
- `lib/services/notification_service.dart` - Notification management service
- `lib/models/notification_model.dart` - Notification data model

**Files to Modify:**
- `lib/main.dart` - Initialize notification service
- `lib/screens/add_service_screen.dart` - Schedule notification when reminder is set
- `lib/screens/edit_service_screen.dart` - Update notification when reminder changes
- `lib/services/hive_service.dart` - Cancel notification when service deleted
- `android/app/src/main/AndroidManifest.xml` - Add notification permissions

**Implementation Steps:**
1. Add dependencies to `pubspec.yaml`
2. Create `NotificationService` class with methods:
   - `initialize()` - Setup notification channels
   - `scheduleServiceReminder(ServiceRecord)` - Schedule notification
   - `cancelNotification(String serviceId)` - Cancel scheduled notification
   - `checkAndShowOverdueReminders()` - Check for overdue services on app launch
3. Add notification permission requests
4. Integrate notification scheduling in add/edit service screens
5. Add notification tap handler to navigate to specific service
6. Create notification icons for Android

**Estimated Time:** 2-3 days

---

## Feature 2: Photo Attachments for Service Bills ✅ COMPLETED

### Objectives
- Attach multiple photos to each service record (receipts, bills, work orders) ✅
- View photos in a gallery within service details ✅
- Delete individual photos ✅
- Compress images to save storage ✅

### Completion Status
**✅ Implemented on December 7, 2025**
- Created ImageService for automatic compression (1920x1080, 85% quality)
- Implemented ServicePhotoGallery widget with 3-column grid display
- Created ServicePhotoViewerScreen with pinch-to-zoom and swipe navigation
- Added photo picker to AddServiceScreen (gallery + camera options)
- Integrated photo management in EditServiceScreen (add/delete)
- Added photo count indicators to VehicleDetailScreen
- All photos stored in organized directory structure: `/service_photos/{serviceId}/`

### Files Created:
- ✅ `lib/services/image_service.dart` - Image compression and storage management
- ✅ `lib/widgets/service_photo_gallery.dart` - Photo grid widget with edit capabilities
- ✅ `lib/screens/service_photo_viewer_screen.dart` - Full-screen photo viewer

### Files Modified:
- ✅ `lib/models/service_model.dart` - Added `List<String>? photosPaths` field
- ✅ `lib/models/service_model.g.dart` - Regenerated Hive adapter with null-safety
- ✅ `lib/screens/add_service_screen.dart` - Added photo picker and gallery display
- ✅ `lib/screens/edit_service_screen.dart` - Added photo management features
- ✅ `lib/screens/vehicle_detail_screen.dart` - Added photo count badge display
- ✅ `pubspec.yaml` - Added flutter_image_compress and photo_view dependencies
- ✅ `lib/models/vehicle_model.g.dart` - Fixed null-safety for color field

### Technical Implementation
**Dependencies:**
- `image_picker: ^1.1.2` (already installed)
- `flutter_image_compress: ^2.1.0` - Image compression
- `photo_view: ^0.14.0` - Image viewer with zoom

**Files to Create:**
- `lib/screens/service_photo_viewer_screen.dart` - Full-screen photo viewer
- `lib/widgets/service_photo_gallery.dart` - Photo grid widget
- `lib/services/image_service.dart` - Image compression and storage

**Files to Modify:**
- `lib/models/service_model.dart` - Add `List<String>? photosPaths` field
- `lib/models/service_model.g.dart` - Regenerate Hive adapter
- `lib/screens/add_service_screen.dart` - Add photo picker for multiple images
- `lib/screens/edit_service_screen.dart` - Add photo management (add/delete)
- `lib/screens/vehicle_detail_screen.dart` - Display photo count badge
- `lib/screens/service_timeline_screen.dart` - Show photo indicator icon

**Implementation Steps:**
1. Update ServiceRecord model with photos list
2. Create ImageService for compression (max 1920x1080, quality 85%)
3. Create photo gallery widget with grid layout
4. Add "Add Photos" button in service form
5. Implement full-screen photo viewer with swipe
6. Add delete confirmation for photos
7. Display photo thumbnails in service cards
8. Regenerate Hive adapters

**Storage Structure:**
```
/app_documents/
  /service_photos/
    /{serviceId}/
      /photo_1.jpg
      /photo_2.jpg
```

**Estimated Time:** 3-4 days

---

## Feature 3: Custom Color Picker

### Objectives
- Allow users to choose any color for vehicles (not limited to 12 presets)
- Provide both preset colors and custom color picker
- Save custom colors to recent/favorites

### Technical Implementation
**Dependencies:**
- `flutter_colorpicker: ^1.0.3` - Color picker dialog

**Files to Create:**
- `lib/widgets/custom_color_picker_dialog.dart` - Color picker widget

**Files to Modify:**
- `lib/screens/add_vehicle_screen.dart` - Add "Custom Color" option
- `lib/screens/edit_vehicle_screen.dart` - Add "Custom Color" option
- `lib/services/hive_service.dart` - Add recent colors storage (optional)

**Implementation Steps:**
1. Add flutter_colorpicker dependency
2. Create CustomColorPickerDialog with:
   - 12 preset colors grid
   - "Choose Custom" button
   - Material/Wheel color picker
   - Recent colors section (last 6 used)
3. Update vehicle screens to use new picker
4. Store recent colors in Hive box (optional)
5. Show color preview in picker

**UI Design:**
- Top section: 12 preset colors (existing)
- Divider with "OR"
- "Pick Custom Color" button
- Recent colors section (if any custom colors used)

**Estimated Time:** 1-2 days

---

## Feature 4: Maintenance Schedule Templates

### Objectives
- Pre-defined service schedules by vehicle type
- Customizable maintenance intervals
- Automatic reminder suggestions based on templates
- Track completion vs scheduled services

### Technical Implementation
**Dependencies:**
- None (use existing packages)

**Files to Create:**
- `lib/models/maintenance_template.dart` - Template data model
- `lib/models/scheduled_maintenance.dart` - Scheduled item model
- `lib/screens/maintenance_template_screen.dart` - Template selection
- `lib/screens/maintenance_schedule_screen.dart` - Schedule view per vehicle
- `lib/widgets/template_card.dart` - Template display card
- `lib/data/default_templates.dart` - Pre-defined templates

**Files to Modify:**
- `lib/screens/vehicle_detail_screen.dart` - Add "Maintenance Schedule" button
- `lib/screens/add_service_screen.dart` - Suggest from template
- `lib/services/hive_service.dart` - Template storage operations

**Implementation Steps:**
1. Create MaintenanceTemplate model:
   ```dart
   class MaintenanceTemplate {
     String id;
     String name;
     String vehicleType; // Sedan, SUV, Truck, Motorcycle
     List<ScheduledMaintenance> items;
   }
   ```

2. Create ScheduledMaintenance model:
   ```dart
   class ScheduledMaintenance {
     String serviceType;
     int? intervalMonths;
     int? intervalKilometers;
     String description;
     bool isCompleted;
     DateTime? lastCompletedDate;
   }
   ```

3. Add default templates:
   - Sedan Template (Oil every 6 months/5000km, Tire rotation 10000km, etc.)
   - SUV Template
   - Truck Template
   - Motorcycle Template

4. Create schedule screen showing:
   - Upcoming services (due soon)
   - Overdue services (in red)
   - Completed services (with checkmark)
   - Next due date/odometer

5. Allow custom template creation
6. Integration with reminders (auto-create reminder from template)

**Estimated Time:** 4-5 days

---

## Feature 5: Dark/Light Theme Toggle ✅ COMPLETED

### Objectives
- User-selectable theme (Light/Dark/System) ✅
- Smooth theme switching without restart ✅
- Persist theme preference ✅
- Update all screens with theme-aware colors ✅

### Completion Status
**✅ Implemented on [Current Date]**
- Created AppTheme class with light and dark themes
- Implemented ThemeProvider using Riverpod with SharedPreferences
- Created SettingsScreen with theme selector (Radio buttons)
- Added settings icon to all main screens (Vehicles, Timeline, Reminders)
- Theme preference persists between app sessions
- All Material Design 3 components automatically adapt to theme

### Files Created:
- ✅ `lib/theme/app_theme.dart` - Light and dark theme definitions
- ✅ `lib/providers/theme_provider.dart` - Theme state management with persistence
- ✅ `lib/screens/settings_screen.dart` - Settings UI with theme selector

### Files Modified:
- ✅ `lib/main.dart` - Updated to use ConsumerWidget and theme provider
- ✅ `lib/screens/vehicle_list_screen.dart` - Added settings navigation
- ✅ `lib/screens/service_timeline_screen.dart` - Added settings navigation
- ✅ `lib/screens/reminders_screen.dart` - Added settings navigation
- ✅ `pubspec.yaml` - Added shared_preferences dependency
- ✅ `APP_README.md` - Documented theme feature

### Technical Implementation
**Dependencies:**
- `shared_preferences: ^2.2.0` - Store theme preference

**Files to Create:**
- `lib/models/theme_mode_preference.dart` - Theme preference model
- `lib/providers/theme_provider.dart` - Theme state management
- `lib/theme/app_theme.dart` - Light and dark theme definitions
- `lib/screens/settings_screen.dart` - Settings with theme toggle

**Files to Modify:**
- `lib/main.dart` - Use theme provider, add settings navigation
- `lib/screens/home_screen.dart` - Add settings icon to AppBar
- All screens using hardcoded colors (migrate to theme colors)

**Implementation Steps:**
1. Create AppTheme class with:
   ```dart
   static ThemeData lightTheme = ThemeData(
     useMaterial3: true,
     brightness: Brightness.light,
     colorScheme: ColorScheme.light(
       primary: Color(0xFF2E7CF6),
       surface: Color(0xFFF5F5F5),
       // ... other colors
     ),
   );
   
   static ThemeData darkTheme = ThemeData(
     useMaterial3: true,
     brightness: Brightness.dark,
     scaffoldBackgroundColor: Color(0xFF0F1419),
     // ... existing dark theme
   );
   ```

2. Create ThemeProvider using Riverpod:
   ```dart
   class ThemeNotifier extends StateNotifier<ThemeMode> {
     ThemeNotifier() : super(ThemeMode.system);
     
     void setTheme(ThemeMode mode) {
       state = mode;
       // Save to shared preferences
     }
   }
   ```

3. Update MyApp to use theme provider:
   ```dart
   theme: AppTheme.lightTheme,
   darkTheme: AppTheme.darkTheme,
   themeMode: ref.watch(themeProvider),
   ```

4. Create SettingsScreen with:
   - Theme mode selector (Radio buttons: Light/Dark/System)
   - About section
   - Version info

5. Replace all hardcoded colors with theme colors:
   - `Color(0xFF1A1F28)` → `Theme.of(context).colorScheme.surface`
   - `Color(0xFF2E7CF6)` → `Theme.of(context).colorScheme.primary`
   - etc.

6. Add settings icon to AppBar in home_screen.dart

**Estimated Time:** 2-3 days

---

## Implementation Priority & Timeline

### Phase 2A (Week 1-2) - Core Enhancements ✅ COMPLETED
**Priority 1 - High Impact:**
1. **Dark/Light Theme Toggle** ✅ COMPLETED (2-3 days)
   - Foundation for better UX
   - Affects all other features
   - **Status:** Fully implemented with light/dark/system options
   - **Completed:** December 7, 2025
   
2. **Photo Attachments for Bills** ✅ COMPLETED (3-4 days)
   - Highly requested feature
   - Important for record keeping
   - **Status:** Fully functional with compression, gallery, and viewer
   - **Completed:** December 7, 2025

### Phase 2B (Week 3-4) - Advanced Features
**Priority 2 - Enhanced Functionality:**
3. **Push Notifications** (2-3 days)
   - Critical for reminders to be useful
   - User retention feature

4. **Maintenance Schedule Templates** (4-5 days)
   - Professional feature
   - Differentiates app

### Phase 2C (Week 5) - Polish
**Priority 3 - Nice to Have:**
5. **Custom Color Picker** (1-2 days)
   - User customization
   - Quick win

**Total Estimated Time:** 4-5 weeks

---

## Updated Dependencies Summary

Add to `pubspec.yaml`:
```yaml
dependencies:
  # Existing dependencies...
  
  # Phase 2 additions
  flutter_local_notifications: ^17.0.0  # Push notifications [PENDING]
  permission_handler: ^11.0.0           # Permissions [PENDING]
  timezone: ^0.9.0                      # Notification scheduling [PENDING]
  flutter_image_compress: ^2.1.0        # Image compression [✅ INSTALLED]
  photo_view: ^0.14.0                   # Photo viewer [✅ INSTALLED]
  flutter_colorpicker: ^1.0.3           # Color picker [PENDING]
  shared_preferences: ^2.2.0            # Theme persistence [✅ INSTALLED]
```

---

## Database Schema Updates

### ServiceRecord Model Changes
```dart
@HiveType(typeId: 1)
class ServiceRecord extends HiveObject {
  // ... existing fields ...
  
  @HiveField(11)
  final List<String>? photosPaths;  // NEW: Service bill photos
}
```

### New Models to Add
```dart
@HiveType(typeId: 2)
class MaintenanceTemplate {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String vehicleType;
  
  @HiveField(3)
  final List<ScheduledMaintenance> items;
}

@HiveType(typeId: 3)
class ScheduledMaintenance {
  @HiveField(0)
  final String serviceType;
  
  @HiveField(1)
  final int? intervalMonths;
  
  @HiveField(2)
  final int? intervalKilometers;
  
  @HiveField(3)
  final String description;
  
  @HiveField(4)
  final bool isCompleted;
  
  @HiveField(5)
  final DateTime? lastCompletedDate;
}
```

---

## Testing Checklist

### Feature Testing
- [ ] Notifications appear at correct time
- [ ] Notification taps navigate to service
- [✅] Photos compress and save correctly
- [✅] Photo gallery displays properly
- [✅] Full-screen photo viewer works
- [ ] Custom colors save and display
- [✅] Theme toggle works instantly
- [✅] Theme persists across app restarts
- [ ] Templates create correct schedules
- [ ] Schedule tracks completion

### Edge Cases
- [ ] Handle 20+ photos per service
- [ ] Notification with deleted service
- [ ] Theme change during photo upload
- [ ] Schedule with overdue items
- [ ] Color picker with invalid values
- [ ] Large image files (>10MB)
- [ ] No camera/gallery permission

### Performance
- [ ] Image compression speed (<2 sec for 5MB image)
- [ ] Theme switch animation smooth
- [ ] Photo gallery scrolling smooth with 50+ photos
- [ ] Notification scheduling batch operations
- [ ] Template loading time (<500ms)

---

## UI/UX Improvements

### Navigation Updates
```
Bottom Navigation Bar:
├── Vehicles (existing)
├── Timeline (existing)
├── Reminders (existing)
└── Settings (NEW)
    ├── Theme Mode
    ├── Notifications
    ├── About
    └── Version

Vehicle Detail Screen (add buttons):
├── Add Service (existing)
├── Maintenance Schedule (NEW)
└── Settings icon → Edit Vehicle
```

### Color Scheme
**Light Theme:**
- Background: `#FFFFFF`
- Surface: `#F5F5F5`
- Primary: `#2E7CF6`
- Text: `#000000`

**Dark Theme (existing):**
- Background: `#0F1419`
- Surface: `#1A1F28`
- Primary: `#2E7CF6`
- Text: `#FFFFFF`

---

## Risk Mitigation

### Potential Issues & Solutions

1. **Notification Reliability**
   - Risk: Notifications may not fire on some devices
   - Solution: Use WorkManager for critical reminders, test on multiple devices

2. **Storage Space**
   - Risk: Too many photos consuming storage
   - Solution: Implement compression, add storage usage indicator, limit to 10 photos per service

3. **Theme Transition Glitches**
   - Risk: UI flicker during theme change
   - Solution: Use AnimatedTheme, preload both themes

4. **Template Complexity**
   - Risk: Users overwhelmed by templates
   - Solution: Start with 4 simple templates, add "Skip" option

5. **Permission Denials**
   - Risk: Users deny camera/notification permissions
   - Solution: Graceful fallback, show explanatory dialogs

---

## Success Metrics

### User Engagement
- [ ] 70%+ users enable notifications
- [ ] Average 2+ photos per service record
- [ ] 50%+ users try custom colors
- [ ] 40%+ users use maintenance templates
- [ ] 30%+ users switch from default theme

### Technical Metrics
- [ ] App size increase <15MB
- [ ] No performance degradation
- [ ] <1% crash rate
- [ ] Photo upload success rate >95%
- [ ] Theme switch time <300ms

---

## Post-Phase 2 Considerations

### Phase 3 Ideas (Future)
- Export service history to PDF
- Cloud backup and sync
- Multi-vehicle comparison charts
- Fuel consumption tracking
- Cost analytics and trends
- Multi-language support
- Widget for quick service entry
- Apple CarPlay/Android Auto integration

---

## Notes

- All features should maintain backward compatibility with Phase 1
- Ensure Hive migrations handle new fields gracefully
- Update APP_README.md after each feature completion
- Create unit tests for new services
- Consider user onboarding tooltips for new features

---

**Last Updated:** December 7, 2025
**Status:** Phase 2A Complete | Phase 2B In Progress
**Progress:** 2 of 5 features completed (40%)
**Next Milestone:** Push Notifications (Phase 2B)
