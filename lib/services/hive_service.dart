import 'package:hive_flutter/hive_flutter.dart';
import '../models/vehicle_model.dart';
import '../models/service_model.dart';

class HiveService {
  static const String _vehicleBoxName = 'vehicleBox';
  static const String _serviceBoxName = 'serviceBox';

  late Box<Vehicle> _vehicleBox;
  late Box<ServiceRecord> _serviceBox;

  /// Initialize Hive and open boxes
  Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(VehicleAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ServiceRecordAdapter());
    }

    // Open boxes
    _vehicleBox = await Hive.openBox<Vehicle>(_vehicleBoxName);
    _serviceBox = await Hive.openBox<ServiceRecord>(_serviceBoxName);
  }

  // ============ VEHICLE OPERATIONS ============

  /// Get all vehicles
  List<Vehicle> getAllVehicles() {
    return _vehicleBox.values.toList();
  }

  /// Add a new vehicle
  Future<void> addVehicle(Vehicle vehicle) async {
    await _vehicleBox.put(vehicle.id, vehicle);
  }

  /// Update an existing vehicle
  Future<void> updateVehicle(Vehicle vehicle) async {
    await _vehicleBox.put(vehicle.id, vehicle);
  }

  /// Delete a vehicle and all its associated service records
  Future<void> deleteVehicle(String id) async {
    // Delete all service records for this vehicle
    final servicesToDelete = _serviceBox.values
        .where((service) => service.vehicleId == id)
        .toList();

    for (var service in servicesToDelete) {
      await _serviceBox.delete(service.id);
    }

    // Delete the vehicle
    await _vehicleBox.delete(id);
  }

  /// Get a vehicle by ID
  Vehicle? getVehicleById(String id) {
    return _vehicleBox.get(id);
  }

  // ============ SERVICE RECORD OPERATIONS ============

  /// Get all service records for a specific vehicle
  List<ServiceRecord> getServiceRecordsForVehicle(String vehicleId) {
    return _serviceBox.values
        .where((service) => service.vehicleId == vehicleId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }

  /// Add a new service record
  Future<void> addServiceRecord(ServiceRecord record) async {
    await _serviceBox.put(record.id, record);
  }

  /// Update an existing service record
  Future<void> updateServiceRecord(ServiceRecord record) async {
    await _serviceBox.put(record.id, record);
  }

  /// Delete a service record
  Future<void> deleteServiceRecord(String id) async {
    await _serviceBox.delete(id);
  }

  /// Get all service records
  List<ServiceRecord> getAllServiceRecords() {
    return _serviceBox.values.toList();
  }

  /// Close all boxes
  Future<void> close() async {
    await _vehicleBox.close();
    await _serviceBox.close();
  }
}
