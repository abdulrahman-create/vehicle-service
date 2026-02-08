# Vehica Service - Vehicle Maintenance Tracker

A professional Flutter application designed for vehicle owners to track maintenance history, manage service costs, and receive localized reminders.

## 🚀 Key Features

*   **Interactive Mapping**: Choose and pin service locations using a crosshair map picker ($ \text{OpenStreetMap} $).
*   **Detailed Analytics**: Filter your service history and expenses by specific **Year and Month**.
*   **Visual History**: Attach photos of bills, receipts, and work orders to every service record.
*   **Connected Timeline**: View your vehicle's entire life story through a glowing, connected vertical timeline.
*   **Dual Tracking**: Set service reminders based on both **Date** and **Odometer** readings.
*   **Cloud Sync**: Securely backup your data to Firebase for cross-device access.
*   **Theme Flexibility**: Full Material 3 support with Light/Dark modes and high-contrast accessibility filtering.

## 🛠 Tech Stack

*   **Frontend**: Flutter (Dart)
*   **State Management**: Riverpod (v2.6)
*   **Database**: Hive (Local) & Firebase Firestore (Cloud Sync)
*   **Notifications**: Flutter Local Notifications (Timezone-sensitive)
*   **Mapping**: Flutter Map (Leaflet-based) & OpenStreetMap

## 📖 Documentation

Detailed technical documentation is available in the following files:

*   [**APP_README.md**](APP_README.md): Comprehensive feature list and project structure.
*   [**PHASE_2_PLAN.md**](PHASE_2_PLAN.md): Detailed development ledger and completion status.
*   [**database_schema.md**](database_schema.md): Firestore document structure and security rules.
*   [**lib/project plan.md**](lib/project%20plan.md): Original technical specifications and model definitions.

## 🚦 Getting Started

1.  **Dependencies**: Run `flutter pub get` to install all required packages.
2.  **Code Generation**: Run `flutter pub run build_runner build` to generate database adapters.
3.  **Run**: Launch the app using `flutter run` on your preferred device.

---
*Created with focus on stability and Malaysian Ringgit ($ \text{MYR} $) support.*
