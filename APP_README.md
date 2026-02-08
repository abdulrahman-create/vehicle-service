# Vehicle Service Tracker

A Flutter mobile application for tracking vehicle maintenance and service records with Malaysian Ringgit (MYR) currency support, vehicle photos, custom colors, and timeline view.

## Features

- **Vehicle Management**
  - Add multiple vehicles with make, model, year, VIN, and current mileage
  - **Vehicle Photos** - Add photos from gallery or camera for each vehicle
  - **Custom Colors** - Choose from 12 colors to personalize each vehicle
  - **Edit Vehicles** - Update vehicle details, photos, and colors anytime
  - View all vehicles in a scrollable list with color-coded cards
  - Delete vehicles and their associated service records
  - Track current mileage automatically

- **Service Records**
  - Track complete service history for each vehicle
  - Record service type, date, cost (in MYR), odometer reading, description, and location
  - **Add historical records** - No restrictions on odometer readings (can add old service records)
  - **Edit existing service records** - Tap any service record to edit all details
  - **Swipe to delete** - Swipe left on any service record to delete with confirmation
  - **Service Location** - Record where service was performed (manual entry, GPS, or Map Pin)
  - **Interactive Map Picker** - Choose service locations by pinning them on a map with a crosshair and address search
  - **Map Navigation** - Tap any saved service location to launch it in external map apps (Google Maps, Apple Maps)
  - **GPS Integration** - Use current location button to auto-fill service location
  - **Service Reminders** - Set reminders for upcoming services by date or odometer reading
  - Calculate total maintenance cost per vehicle in Malaysian Ringgit (MYR)
  - Service types include: Oil Change, Tire Rotation, Tire Change, Brake Service, Engine Repair, Transmission Service, Battery Replacement, Air Filter, Coolant, Inspection, and Other

- **Service Reminders & Notifications**
  - **Smart Push Notifications** - Receive local notifications on your device for upcoming services
  - **Automatic Scheduling** - Reminders are automatically scheduled for 9:00 AM on the target date
  - **Set Reminders** - Add reminders when creating service records
  - **Date-based Reminders** - Get reminded on a specific date for next service
  - **Odometer-based Reminders** - Set reminders for specific mileage
  - **Dual Reminders** - Combine both date and odometer reminders
  - **Upcoming Reminders View** - Dedicated tab showing all upcoming services
  - **Overdue Indicators** - Visual alerts for overdue services
  - **Timeline Integration** - Reminder indicators shown in service timeline

- **User Interface & Experience**
  - Material Design 3 with **Dark/Light Theme Toggle**
  - **High-Contrast Design** - Specialized Light Mode auditing for better outdoor visibility
  - **Connected Timeline** - A glowing, connected vertical timeline showing your vehicle's history across all cars
  - **Filtered Analytics** - Filter service history and costs by specific Year and Month
  - **Legacy Data Stability** - Intelligent database adapters that gracefully handle missing fields in older app versions
  - **Settings Screen** - Configure app preferences including theme selection
  - **Theme Options** - Choose between Light, Dark, or System theme
  - **Persistent Theme** - Selected theme saves and persists between sessions
  - **Bottom Navigation** - Switch between Vehicles, Timeline, and Reminders views
  - **Service Timeline** - Chronological view of all service records across vehicles
  - **Search Functionality** - Filter service records by type, description, or vehicle
  - Color-coded vehicle indicators in timeline
  - Instant refresh - Service records display immediately after saving
  - Empty state screens with helpful messages
  - Form validation on all inputs
  - Date picker for service dates
  - Visual color picker with 12 color options
  - Image source selection (Gallery/Camera)
  - Confirmation dialogs for destructive actions

- **Data Persistence**
  - Local storage using Hive database
  - All data persists between app sessions
  - No internet connection required

## Technology Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Local Database**: Hive
- **Architecture**: Clean architecture with separate layers:
  - Models (Data layer)
  - Services (Database operations)
  - Providers (State management)
  - Screens (UI layer)

## Project Structure

```
lib/
├── main.dart                          # App entry point with Hive initialization & theme provider
├── models/
│   ├── vehicle_model.dart             # Vehicle data model (id, make, model, year, VIN, mileage, imagePath, color)
│   ├── vehicle_model.g.dart           # Generated Hive adapter
│   ├── service_model.dart             # Service record data model (with reminder & location fields)
│   └── service_model.g.dart           # Generated Hive adapter
├── services/
│   ├── hive_service.dart              # Hive database service (CRUD operations)
│   ├── firestore_service.dart         # Cloud sync and backup service
│   ├── location_service.dart          # GPS location service (get current location, geocoding)
│   ├── notification_service.dart      # Local push notification scheduling
│   └── image_service.dart             # Photo storage and compression logic
├── providers/
│   ├── vehicle_provider.dart          # Riverpod state management
│   ├── auth_provider.dart             # Firebase Authentication logic
│   └── theme_provider.dart            # Theme state management with SharedPreferences
├── theme/
│   └── app_theme.dart                 # Light and dark theme definitions
└── screens/
    ├── home_screen.dart               # Main screen with bottom navigation (Vehicles/Timeline/Reminders)
    ├── vehicle_list_screen.dart       # Vehicle list with color-coded cards and images
    ├── vehicle_detail_screen.dart     # Vehicle details with edit button and service history
    ├── add_vehicle_screen.dart        # Add vehicle form with photo and color picker
    ├── edit_vehicle_screen.dart       # Edit vehicle details, photo, and color
    ├── add_service_screen.dart        # Add service record form with reminder options
    ├── edit_service_screen.dart       # Edit existing service record form
    ├── map_picker_screen.dart         # Interactive map location picker
    ├── service_timeline_screen.dart   # Chronological timeline view of all services with search
    ├── service_photo_viewer_screen.dart # Pinch-to-zoom photo gallery
    ├── reminders_screen.dart          # Upcoming reminders view with overdue indicators
    ├── settings_screen.dart           # App settings with theme selector
    └── signup_screen.dart             # Cloud sync account creation
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code with Flutter extensions
- Android device or emulator

### Installation

1. Clone the repository
2. Navigate to the project directory:
   ```bash
   cd vehica_service
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Generate Hive type adapters:
   ```bash
   dart run build_runner build
   ```

5. Run the app:
   ```bash
   flutter run
   ```

### Building for Android

To build a release APK:
```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

## Usage

### Vehicle Management
1. **Add a Vehicle**: Tap the + button on the Vehicles tab
   - Fill in make, model, year, VIN, and current mileage
   - Tap the image area to add a vehicle photo (from gallery or camera)
   - Choose a color from 12 available options
   - All costs displayed in Malaysian Ringgit (MYR)

2. **Edit a Vehicle**: From vehicle detail screen, tap the edit icon
   - Update any vehicle information
   - Change or remove the vehicle photo
   - Select a different color

3. **View Vehicle Details**: Tap on any vehicle card to see details and service history
   - Vehicle info displayed with custom color and photo
   - Complete service history listed chronologically
   - Total maintenance cost calculated automatically in MYR

4. **Delete Vehicle**: Tap the three-dot menu in vehicle details (removes vehicle and all its service records)

### Service Records
5. **Add Service Record**: From the vehicle detail screen, tap "Add Service"
   - Can add historical records with any odometer reading
   - Choose from 11 service types or select "Other"
   - Optional: Add service location manually or use GPS
   - Optional: Set reminders for next service
   - Costs displayed in Malaysian Ringgit (MYR)

6. **Edit Service Record**: Tap on any service record card to edit its details
   - Modify date, type, cost, odometer, description, or location
   - Update location using GPS or manual entry
   - Changes save immediately

7. **Delete Service Record**: Swipe left on a service record to delete it (with confirmation)

### Service Location
8. **Record Location**: When adding/editing service records
   - Manually type the service location (shop name, address)
   - Or tap the GPS button (📍) to auto-fill current location
   - Location appears in timeline with location icon

### Service Reminders
9. **Set a Reminder**: When adding a service record, toggle "Service Reminder" switch
   - Choose a reminder date for time-based reminders
   - Or set an odometer reading for mileage-based reminders
   - Or use both for comprehensive tracking

10. **View Upcoming Reminders**: Navigate to the Reminders tab
    - See all upcoming services sorted by date/mileage
    - Overdue reminders marked with red indicator
    - View vehicle details and last service information

### Timeline View
11. **Search Services**: Use the search bar in Timeline view
    - Filter by service type, description, or vehicle
    - Real-time filtering as you type
    - Clear button to reset search

12. **View Service Timeline**: Tap the Timeline tab in bottom navigation
    - See all service records from all vehicles in chronological order
    - Each entry shows vehicle info with custom color indicator
    - Service locations displayed when available
    - Quick overview of maintenance history across your fleet

### Theme Customization
13. **Change App Theme**: Tap the settings icon (⚙️) in the top-right corner of any screen
    - Choose from Light, Dark, or System theme
    - Light Theme: Clean white backgrounds with blue accents
    - Dark Theme: Dark backgrounds optimized for low-light use
    - System Theme: Automatically follows device settings
    - Selected theme is saved and persists between app sessions

## Key Functionality

### Vehicle Customization
- **Photos**: Add vehicle photos from gallery or camera
- **Colors**: Choose from 12 predefined colors:
  1. Blue (default)
  2. Red
  3. Green
  4. Orange
  5. Purple
  6. Cyan
  7. Yellow
  8. Pink
  9. Blue Grey
  10. Brown
  11. Light Green
  12. Light Blue
- **Edit Anytime**: Update vehicle details, photos, and colors at any time

### Service Record Management
- **Add**: No odometer restrictions - can add old maintenance history
- **Edit**: Tap any service record to modify date, type, cost, odometer, or description
- **Delete**: Swipe left for quick deletion with confirmation dialog
- **Instant Update**: Changes reflect immediately without page refresh

### Service Types Available
1. Oil Change
2. Tire Rotation
3. Tire Change
4. Brake Service
5. Engine Repair
6. Transmission Service
7. Battery Replacement
8. Air Filter
9. Coolant
10. Inspection
11. Other

### Navigation
- **Vehicles Tab**: Main vehicle list with color-coded cards
- **Timeline Tab**: Chronological view of all service records across all vehicles with search
- **Reminders Tab**: Upcoming service reminders with overdue alerts

## Data Models

### Vehicle
- ID (unique identifier)
- Make
- Model
- Year
- VIN (optional)
- Current Mileage
- Image Path (photo storage location)
- Color (integer color value, 12 predefined options)

### Service Record
- ID (unique identifier)
- Vehicle ID (foreign key)
- Date
- Service Type
- Description
- Cost
- Odometer Reading
- Service Location (optional, GPS or manual)
- Reminder Date (optional)
- Reminder Odometer (optional)
- Has Reminder (boolean flag)
- Odometer Reading

## Dependencies

- `flutter_riverpod: ^2.6.1` - State management
- `hive: ^2.2.3` - Local database
- `hive_flutter: ^1.1.0` - Hive Flutter integration
- `path_provider: ^2.1.5` - File system paths
- `intl: ^0.20.1` - Date formatting
- `uuid: ^4.5.1` - Unique ID generation
- `image_picker: ^1.1.2` - Camera and gallery image selection
- `timeline_list: ^0.1.1` - Timeline visualization components
- `geolocator: ^13.0.2` - GPS location services
- `geocoding: ^3.0.0` - Convert GPS coordinates to addresses
- `shared_preferences: ^2.2.0` - Persistent theme preference storage

## Development

### Code Generation

When you modify Hive models, regenerate type adapters:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Or clean and rebuild:
```bash
dart run build_runner clean
dart run build_runner build
```

## Android Configuration

The app is configured with Android NDK version 27.0.12077973 for compatibility with all plugins.

Located in: `android/app/build.gradle.kts`
```kotlin
android {
    ndkVersion = "27.0.12077973"
    ...
}
```

## Troubleshooting

### Installation Issues on Android Device
If you get `INSTALL_FAILED_USER_RESTRICTED` error:
1. Enable Developer Options on your device (tap Build Number 7 times)
2. Enable "USB debugging" and "Install via USB"
3. Accept the installation prompt on your device

### White Screen on Launch
- Ensure Hive is properly initialized in `main.dart`
- Check that generated type adapters exist (`.g.dart` files)
- Run `dart run build_runner build` if adapters are missing

### Service Records Not Updating
- The app uses `ref.invalidate(vehicleProvider)` to force refresh
- Changes should appear immediately after saving

### Location Permission Issues
- If GPS location fails, check that location permissions are granted in device settings
- Enable location services on your device
- The app will request permissions automatically on first use

## Permissions

### Android
The app requires the following permissions (declared in `AndroidManifest.xml`):
- `ACCESS_FINE_LOCATION` - For precise GPS location when recording service locations
- `ACCESS_COARSE_LOCATION` - For approximate location (fallback)
- `CAMERA` - For taking vehicle photos (via image_picker)
- `READ_EXTERNAL_STORAGE` - For selecting photos from gallery
- `WRITE_EXTERNAL_STORAGE` - For saving photos

## Currency Format
All monetary values are displayed in Malaysian Ringgit (MYR) with the "RM" prefix.
- Example: RM 150.00

## Current Features Summary
✅ Vehicle management with photos and 12 custom colors
✅ Service record tracking with full edit/delete capability
✅ Service location recording (GPS or manual entry)
✅ Service reminders (date-based and odometer-based)
✅ Service timeline with search functionality
✅ Upcoming reminders view with overdue indicators
✅ Bottom navigation (Vehicles/Timeline/Reminders)
✅ Local Hive database with data persistence
✅ Dark theme Material Design 3 UI
✅ Malaysian Ringgit (MYR) currency support

## Future Enhancements
Potential features for future development:
- ✅ ~~Service reminders based on date or mileage~~ (COMPLETED)
- ✅ ~~Search and filter functionality~~ (COMPLETED)
- ✅ ~~GPS location integration~~ (COMPLETED)
- Export service history to PDF/CSV
- Push notifications for reminders
- Multiple currency support
- Cloud backup and sync
- Fuel consumption tracking
- Multiple photos per vehicle (photo gallery)
- Photo attachments for individual service records
- Custom color picker (beyond 12 presets)
- Statistics and charts (cost trends, service frequency)
- Maintenance schedule templates
- Parts inventory tracking
- Warranty tracking
- Insurance information storage
- Dark/light theme toggle
- Multi-language support

## License

This project is created as a demonstration application.
