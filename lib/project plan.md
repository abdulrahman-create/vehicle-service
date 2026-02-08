# **Technical Specification for AI Code Generation: Vehicle Service Tracker App**

This document serves as a detailed instruction set for generating the Flutter mobile application codebase. The code must adhere strictly to the architecture and feature requirements outlined below.

## **1\. Project Configuration and Technology Stack**

### **1.1 Core Requirements (Hardened)**

* **Platform:** Flutter (Dart).  
* **Architecture:** Clean structure with distinct layers (Data, Services, State/Provider, UI/Screens).  
* **State Management:** **Riverpod** (using flutter\_riverpod).  
* **Local Database:** **Hive** (using hive\_flutter).  
* **Dependencies:** Must include flutter\_riverpod, hive, hive\_flutter, path\_provider, and intl for date formatting.

### **1.2 Data Models (Hive Objects)**

All models must be annotated for Hive serialization.

#### **A. Vehicle Model (lib/models/vehicle\_model.dart)**

| Field | Type | Hive Field ID | Description |
| :---- | :---- | :---- | :---- |
| id | String | 0 | Unique identifier (use DateTime.now().toIso8601String() or uuid). |
| make | String | 1 | Vehicle manufacturer. |
| model | String | 2 | Vehicle model name. |
| year | int | 3 | Manufacturing year. |
| vin | String | 4 | Vehicle Identification Number (optional, but store if provided). |
| currentMileage | int | 5 | Last recorded mileage. |

#### **B. Service Record Model (lib/models/service\_model.dart)**

| Field | Type | Hive Field ID | Description |
| :---- | :---- | :---- | :---- |
| id | String | 0 | Unique identifier. |
| vehicleId | String | 1 | **Foreign Key** linking back to the Vehicle model. |
| date | DateTime | 2 | Date the service was performed. |
| description | String | 3 | Detailed description of the work done. |
| cost | double | 4 | Total cost of the service. |
| odometerReading | int | 5 | Mileage at the time of service. |
| serviceType | String | 6 | Type of service (e.g., 'Oil Change', 'Tires', 'Repair'). |
| hasReminder | bool | 9 | Whether a reminder is enabled. |
| serviceLocation | String? | 10 | Location name or address. |
| photosPaths | List<String>? | 11 | Attached photo file paths. |
| latitude | double? | 12 | GPS coordinate. |
| longitude | double? | 13 | GPS coordinate. |

## **2\. Data and Service Layer Implementation**

### **2.1 Hive Database Service (lib/services/hive\_service.dart)**

* Create a class (HiveService) responsible for initializing Hive, registering the TypeAdapters, and managing the two main boxes: vehicleBox and serviceBox.  
* **Initialization:** Must be called in main() before runApp().

### **2.2 Repository/Data Access Layer**

* The HiveService must expose the following asynchronous methods:  
  * getAllVehicles(): Returns List\<Vehicle\>.  
  * addVehicle(Vehicle vehicle): Saves a new vehicle.  
  * deleteVehicle(String id): Removes a vehicle and **all associated service records**.  
  * getServiceRecordsForVehicle(String vehicleId): Returns List\<ServiceRecord\>.  
  * addServiceRecord(ServiceRecord record): Saves a new record.

## **3\. State Management (Riverpod)**

### **3.1 Vehicle Provider (lib/providers/vehicle\_provider.dart)**

* Use a **StateNotifier** (or AsyncNotifier) class named VehicleNotifier to hold and manage the application state.  
* **State:** The state should primarily be a List\<Vehicle\>.  
* **Notifier Responsibilities:**  
  * Loading all data on startup.  
  * Exposing methods to call the HiveService and update the local state: addVehicle, deleteVehicle, addServiceRecord.  
  * Calculating and exposing a map or list of services grouped by vehicle.

## **4\. User Interface (UI) Components**

The UI must be adaptive, using standard Flutter Material design principles.

### **4.1 Main Screen (lib/screens/vehicle\_list\_screen.dart)**

* Displays a scrolling list of all vehicles.  
* Each vehicle card should display: Make, Model, Year, and Current Mileage.  
* Tapping a card navigates to the VehicleDetailScreen.  
* A Floating Action Button (FAB) navigates to the AddVehicleScreen.

### **4.2 Vehicle Detail Screen (lib/screens/vehicle\_detail\_screen.dart)**

* Accepts the Vehicle object as an argument.  
* Displays the vehicle's core details (VIN, etc.).  
* Shows a segmented list of **Service Records** for that specific vehicle.  
* Calculates and displays the **Total Maintenance Cost** for the vehicle.  
* Includes a FAB or button to navigate to the AddServiceScreen.

### **4.3 Add Vehicle Screen (lib/screens/add\_vehicle\_screen.dart)**

* A form with input fields for: Make, Model, Year, VIN (Optional), and Initial/Current Mileage.  
* Input validation is required (e.g., Year is a valid number, Mileage is not negative).  
* On submission, calls the addVehicle method in the VehicleNotifier.

### **4.4 Add Service Screen (lib/screens/add\_service\_screen.dart)**

* A form with input fields for:  
  * Date (using a Date Picker).  
  * Service Type (Dropdown or text input).  
  * Description (Text area).  
  * Odometer Reading (Must be equal to or greater than the last recorded odometer reading).  
  * Cost (Numeric input).  
* On submission, creates a ServiceRecord and calls addServiceRecord in the VehicleNotifier.

## **5\. Feature Implementation Details**

### **5.1 Mileage Validation**

When adding a new service record, the entered odometerReading must be validated against the vehicle's currentMileage (which is the highest reading from all previous service records). The new reading must be equal to or greater than the last recorded mileage.

### **5.2 Service Reminders (Basic)**

* The ServiceRecord model should be extended temporarily within the logic to include a simple reminder flag.  
* A separate function in the UI should allow users to set a *future* date for a reminder, which is then stored in the Hive box. (No need for background services in this MVP).  
* The VehicleListScreen should visually highlight vehicles with an overdue or upcoming reminder.

**Summary for AI Code Generation:** Please generate a single, complete Flutter project in the specified structure, implementing all models, services (Hive), state management (Riverpod), and the four core UI screens, adhering to the requirements in Sections 1 through 5\.