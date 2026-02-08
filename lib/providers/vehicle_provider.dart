import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle_model.dart';
import '../models/service_model.dart';
import '../services/hive_service.dart';
import '../services/firestore_service.dart';
import '../main.dart';

// Provider for HiveService - uses the global initialized instance
final hiveServiceProvider = Provider<HiveService>((ref) {
  return hiveService;
});

// Provider for FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// A provider to track syncing status
final isSyncingProvider = StateProvider<bool>((ref) => false);

// StateNotifier for managing vehicles and service records
class VehicleNotifier extends StateNotifier<List<Vehicle>> {
  final HiveService _hiveService;
  final FirestoreService _firestoreService;
  final Ref _ref;

  VehicleNotifier(this._hiveService, this._firestoreService, this._ref)
    : super([]) {
    _loadVehicles();
  }

  // Set syncing status
  void _setSyncing(bool value) {
    _ref.read(isSyncingProvider.notifier).state = value;
  }

  // Load all vehicles from Hive
  void _loadVehicles() {
    state = _hiveService.getAllVehicles();
  }

  // Add a new vehicle
  Future<void> addVehicle(Vehicle vehicle) async {
    _setSyncing(true);
    try {
      await _hiveService.addVehicle(vehicle);
      await _firestoreService.saveVehicle(vehicle);
      _loadVehicles();
    } finally {
      _setSyncing(false);
    }
  }

  // Update an existing vehicle
  Future<void> updateVehicle(Vehicle vehicle) async {
    _setSyncing(true);
    try {
      await _hiveService.updateVehicle(vehicle);
      await _firestoreService.saveVehicle(vehicle);
      _loadVehicles();
    } finally {
      _setSyncing(false);
    }
  }

  // Delete a vehicle and all its service records
  Future<void> deleteVehicle(String id) async {
    _setSyncing(true);
    try {
      await _hiveService.deleteVehicle(id);
      await _firestoreService.deleteVehicle(id);
      _loadVehicles();
    } finally {
      _setSyncing(false);
    }
  }

  // Add a service record and update vehicle mileage if needed
  Future<void> addServiceRecord(ServiceRecord record) async {
    _setSyncing(true);
    try {
      await _hiveService.addServiceRecord(record);
      await _firestoreService.saveService(record);

      // Update vehicle's current mileage if this service has a higher odometer reading
      final vehicle = _hiveService.getVehicleById(record.vehicleId);
      if (vehicle != null) {
        if (record.odometerReading > vehicle.currentMileage) {
          vehicle.currentMileage = record.odometerReading;
          await _hiveService.updateVehicle(vehicle);
          await _firestoreService.saveVehicle(vehicle);
        }

        // Schedule notification if it has a reminder
        if (record.hasReminder && record.reminderDate != null) {
          await notificationService.scheduleServiceReminder(
            vehicle: vehicle,
            service: record,
          );
        }
      }
      _loadVehicles();
    } finally {
      _setSyncing(false);
    }
  }

  // Update a service record
  Future<void> updateServiceRecord(ServiceRecord record) async {
    _setSyncing(true);
    try {
      await _hiveService.updateServiceRecord(record);
      await _firestoreService.saveService(record);

      // Update notification if it has a reminder
      final vehicle = _hiveService.getVehicleById(record.vehicleId);
      if (vehicle != null) {
        if (record.hasReminder && record.reminderDate != null) {
          await notificationService.scheduleServiceReminder(
            vehicle: vehicle,
            service: record,
          );
        } else {
          await notificationService.cancelReminder(record.id);
        }
      }

      _loadVehicles();
    } finally {
      _setSyncing(false);
    }
  }

  // Delete a service record
  Future<void> deleteServiceRecord(String serviceId) async {
    _setSyncing(true);
    try {
      await _hiveService.deleteServiceRecord(serviceId);
      await _firestoreService.deleteService(serviceId);
      await notificationService.cancelReminder(serviceId);
      _loadVehicles();
    } finally {
      _setSyncing(false);
    }
  }

  // Get service records for a specific vehicle
  List<ServiceRecord> getServiceRecordsForVehicle(String vehicleId) {
    return _hiveService.getServiceRecordsForVehicle(vehicleId);
  }

  // Get total maintenance cost for a vehicle
  double getTotalMaintenanceCost(String vehicleId, {int? year, int? month}) {
    final services = _hiveService.getServiceRecordsForVehicle(vehicleId);
    return services
        .where((service) {
          if (year != null && service.date.year != year) return false;
          if (month != null && service.date.month != month) return false;
          return true;
        })
        .fold(0.0, (sum, service) => sum + service.cost);
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

  /// Batch sync local Hive data to Firestore
  Future<void> syncLocalToCloud() async {
    _setSyncing(true);
    try {
      final vehicles = _hiveService.getAllVehicles();
      final List<ServiceRecord> allServices = [];
      for (var vehicle in vehicles) {
        allServices.addAll(
          _hiveService.getServiceRecordsForVehicle(vehicle.id),
        );
      }

      if (vehicles.isNotEmpty || allServices.isNotEmpty) {
        await _firestoreService.syncLocalToCloud(vehicles, allServices);
      }
    } finally {
      _setSyncing(false);
    }
  }

  /// Batch sync cloud Firestore data to local Hive
  Future<void> syncCloudToLocal() async {
    _setSyncing(true);
    try {
      final vehicles = await _firestoreService.getVehicles();
      for (var vehicle in vehicles) {
        await _hiveService.addVehicle(vehicle);
        final services = await _firestoreService.getServices(vehicle.id);
        for (var service in services) {
          await _hiveService.addServiceRecord(service);
        }
      }
      _loadVehicles();
    } finally {
      _setSyncing(false);
    }
  }
}

// Analytics filters
final analyticsYearFilterProvider = StateProvider<int?>((ref) => null);
final analyticsMonthFilterProvider = StateProvider<int?>((ref) => null);

// Provider to get service costs grouped by type for a specific vehicle
final costByTypeProvider = Provider.family<Map<String, double>, String>((
  ref,
  vehicleId,
) {
  final year = ref.watch(analyticsYearFilterProvider);
  final month = ref.watch(analyticsMonthFilterProvider);

  final services = ref
      .watch(vehicleProvider.notifier)
      .getServiceRecordsForVehicle(vehicleId);

  final filteredServices = services.where((service) {
    if (year != null && service.date.year != year) return false;
    if (month != null && service.date.month != month) return false;
    return true;
  });

  final Map<String, double> costMap = {};

  for (var service in filteredServices) {
    costMap[service.serviceType] =
        (costMap[service.serviceType] ?? 0.0) + service.cost;
  }

  return costMap;
});

// Provider for VehicleNotifier
final vehicleProvider = StateNotifierProvider<VehicleNotifier, List<Vehicle>>((
  ref,
) {
  final hiveService = ref.watch(hiveServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  return VehicleNotifier(hiveService, firestoreService, ref);
});

// Provider to get service records for a specific vehicle
final serviceRecordsProvider = Provider.family<List<ServiceRecord>, String>((
  ref,
  vehicleId,
) {
  final notifier = ref.watch(vehicleProvider.notifier);
  return notifier.getServiceRecordsForVehicle(vehicleId);
});

// Provider to get all-time total maintenance cost for a specific vehicle
final totalCostProvider = Provider.family<double, String>((ref, vehicleId) {
  final notifier = ref.watch(vehicleProvider.notifier);
  return notifier.getTotalMaintenanceCost(vehicleId);
});

// Provider to get filtered total maintenance cost for a specific vehicle
final filteredTotalCostProvider = Provider.family<double, String>((
  ref,
  vehicleId,
) {
  final year = ref.watch(analyticsYearFilterProvider);
  final month = ref.watch(analyticsMonthFilterProvider);
  final notifier = ref.watch(vehicleProvider.notifier);
  return notifier.getTotalMaintenanceCost(vehicleId, year: year, month: month);
});
