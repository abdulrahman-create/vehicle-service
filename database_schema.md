# Vehica Service - Database Schema (Firestore)

Since Firebase Firestore is NoSQL, data is stored in **Collections** and **Documents**. This document translates our data model into a structured format for your reference.

## 1. Hierarchy Overview
All data is partitioned by User ID (`uid`) to ensure data privacy.

```text
/users/{uid}/
    ├── (User Profile fields)
    ├── vehicles/
    │   └── {vehicleId}/
    │       └── (Vehicle fields)
    └── services/
        └── {serviceId}/
            └── (Service Record fields)
```

## 2. Collections & Fields

### **Vehicles**
*Collection: `/users/{uid}/vehicles/`*

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | String | Unique Identifier (UUID) |
| `make` | String | Vehicle Manufacturer (e.g., Toyota) |
| `model` | String | Vehicle Model (e.g., Corolla) |
| `year` | Number | Manufacturing Year |
| `color` | Number | Hex color value (Int) |
| `currentMileage` | Number | Latest odometer reading (Calculated) |
| `vin` | String | Vehicle Identification Number (Optional) |
| `imagePath` | String | Local path or Cloud URL to vehicle image |

### **Service Records**
*Collection: `/users/{uid}/services/`*

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | String | Unique Identifier (UUID) |
| `vehicleId` | String | Foreign Key (links to a vehicle ID) |
| `serviceType` | String | Type of service (e.g., Oil Change) |
| `cost` | Number | Cost in RM |
| `date` | Timestamp | Date of service |
| `odometerReading` | Number | Mileage at time of service |
| `description` | String | Detailed notes |
| `hasReminder` | Boolean | Notification status |
| `reminderDate` | Timestamp | Date to trigger notification |
| `serviceLocation` | String | Formatted address of service |
| `latitude` | Number | GPS Latitude coordinate |
| `longitude` | Number | GPS Longitude coordinate |
| `photosPaths` | List<String> | Array of paths to attached photos |

---

## 3. Security Rules (Applied)
The rules in [firestore.rules](firestore.rules) enforce the following:
1. **Authentication Required**: Only logged-in users can access data.
2. **User Isolation**: A user can **only** read or write data where the `{userId}` in the path matches their own `request.auth.uid`.
3. **Validation**: Sub-collections (vehicles/services) inherit the same protection.
