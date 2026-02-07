import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle_model.dart';
import '../models/service_model.dart';
import '../services/hive_service.dart';
import '../main.dart';

// Provider for HiveService - uses the global initialized instance
final hiveServiceProvider = Provider<HiveService>((ref) {
  return hiveService;
});

// StateNotifier for managing vehicles and service records
class VehicleNotifier extends StateNotifier<List<Vehicle>> {
  final HiveService _hiveService;

  VehicleNotifier(this._hiveService) : super([]) {
    _loadVehicles();
  }

  // Load all vehicles from Hive
  void _loadVehicles() {
    state = _hiveService.getAllVehicles();
  }

  // Add a new vehicle
  Future<void> addVehicle(Vehicle vehicle) async {
    await _hiveService.addVehicle(vehicle);
    _loadVehicles();
  }

  // Update an existing vehicle
  Future<void> updateVehicle(Vehicle vehicle) async {
    await _hiveService.updateVehicle(vehicle);
    _loadVehicles();
  }

  // Delete a vehicle and all its service records
  Future<void> deleteVehicle(String id) async {
    await _hiveService.deleteVehicle(id);
    _loadVehicles();
  }

  // Add a service record and update vehicle mileage if needed
  Future<void> addServiceRecord(ServiceRecord record) async {
    await _hiveService.addServiceRecord(record);

    // Update vehicle's current mileage if this service has a higher odometer reading
    final vehicle = _hiveService.getVehicleById(record.vehicleId);
    if (vehicle != null && record.odometerReading > vehicle.currentMileage) {
      vehicle.currentMileage = record.odometerReading;
      await _hiveService.updateVehicle(vehicle);
    }

    _loadVehicles();
  }

  // Get service records for a specific vehicle
  List<ServiceRecord> getServiceRecordsForVehicle(String vehicleId) {
    return _hiveService.getServiceRecordsForVehicle(vehicleId);
  }

  // Get total maintenance cost for a vehicle
  double getTotalMaintenanceCost(String vehicleId) {
    final services = _hiveService.getServiceRecordsForVehicle(vehicleId);
    return services.fold(0.0, (sum, service) => sum + service.cost);
  }

  // Get the highest odometer reading for a vehicle
  int getHighestOdometerReading(String vehicleId) {
    final services = _hiveService.getServiceRecordsForVehicle(vehicleId);
    if (services.isEmpty) {
      final vehicle = _hiveService.getVehicleById(vehicleId);
      return vehicle?.currentMileage ?? 0;
    }
    return services
        .map((s) => s.odometerReading)
        .reduce((a, b) => a > b ? a : b);
  }
}

// Provider for VehicleNotifier
final vehicleProvider = StateNotifierProvider<VehicleNotifier, List<Vehicle>>((
  ref,
) {
  final hiveService = ref.watch(hiveServiceProvider);
  return VehicleNotifier(hiveService);
});

// Provider to get service records for a specific vehicle
final serviceRecordsProvider = Provider.family<List<ServiceRecord>, String>((
  ref,
  vehicleId,
) {
  final notifier = ref.watch(vehicleProvider.notifier);
  return notifier.getServiceRecordsForVehicle(vehicleId);
});

// Provider to get total maintenance cost for a specific vehicle
final totalCostProvider = Provider.family<double, String>((ref, vehicleId) {
  final notifier = ref.watch(vehicleProvider.notifier);
  return notifier.getTotalMaintenanceCost(vehicleId);
});
