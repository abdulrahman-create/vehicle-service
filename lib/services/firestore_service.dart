import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vehicle_model.dart';
import '../models/service_model.dart';
import 'dart:developer' as developer;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // ============ VEHICLE OPERATIONS ============

  /// Sync a vehicle to Firestore
  Future<void> saveVehicle(Vehicle vehicle) async {
    if (_userId == null) return;

    try {
      await _db
          .collection('users')
          .doc(_userId)
          .collection('vehicles')
          .doc(vehicle.id)
          .set(vehicle.toMap());
    } catch (e) {
      developer.log('Error saving vehicle to Firestore', error: e.toString());
    }
  }

  /// Delete a vehicle from Firestore
  Future<void> deleteVehicle(String vehicleId) async {
    if (_userId == null) return;

    try {
      // First delete all service records for this vehicle in Firestore
      final services =
          await _db
              .collection('users')
              .doc(_userId)
              .collection('services')
              .where('vehicleId', isEqualTo: vehicleId)
              .get();

      final batch = _db.batch();
      for (var doc in services.docs) {
        batch.delete(doc.reference);
      }

      // Then delete the vehicle
      batch.delete(
        _db
            .collection('users')
            .doc(_userId)
            .collection('vehicles')
            .doc(vehicleId),
      );

      await batch.commit();
    } catch (e) {
      developer.log(
        'Error deleting vehicle from Firestore',
        error: e.toString(),
      );
    }
  }

  /// Get all vehicles from Firestore
  Future<List<Vehicle>> getVehicles() async {
    if (_userId == null) return [];

    try {
      final snapshot =
          await _db
              .collection('users')
              .doc(_userId)
              .collection('vehicles')
              .get();

      return snapshot.docs.map((doc) => Vehicle.fromMap(doc.data())).toList();
    } catch (e) {
      developer.log(
        'Error getting vehicles from Firestore',
        error: e.toString(),
      );
      return [];
    }
  }

  // ============ SERVICE OPERATIONS ============

  /// Sync a service record to Firestore
  Future<void> saveService(ServiceRecord service) async {
    if (_userId == null) return;

    try {
      await _db
          .collection('users')
          .doc(_userId)
          .collection('services')
          .doc(service.id)
          .set(service.toMap());
    } catch (e) {
      developer.log('Error saving service to Firestore', error: e.toString());
    }
  }

  /// Delete a service record from Firestore
  Future<void> deleteService(String serviceId) async {
    if (_userId == null) return;

    try {
      await _db
          .collection('users')
          .doc(_userId)
          .collection('services')
          .doc(serviceId)
          .delete();
    } catch (e) {
      developer.log(
        'Error deleting service from Firestore',
        error: e.toString(),
      );
    }
  }

  /// Get all services for a vehicle from Firestore
  Future<List<ServiceRecord>> getServices(String vehicleId) async {
    if (_userId == null) return [];

    try {
      final snapshot =
          await _db
              .collection('users')
              .doc(_userId)
              .collection('services')
              .where('vehicleId', isEqualTo: vehicleId)
              .get();

      return snapshot.docs
          .map((doc) => ServiceRecord.fromMap(doc.data()))
          .toList();
    } catch (e) {
      developer.log(
        'Error getting services from Firestore',
        error: e.toString(),
      );
      return [];
    }
  }

  /// Batch sync all local data to Firestore
  Future<void> syncLocalToCloud(
    List<Vehicle> vehicles,
    List<ServiceRecord> services,
  ) async {
    if (_userId == null) return;

    try {
      // Use batches to sync efficiently
      final batch = _db.batch();

      for (var vehicle in vehicles) {
        final docRef = _db
            .collection('users')
            .doc(_userId)
            .collection('vehicles')
            .doc(vehicle.id);
        batch.set(docRef, vehicle.toMap());
      }

      for (var service in services) {
        final docRef = _db
            .collection('users')
            .doc(_userId)
            .collection('services')
            .doc(service.id);
        batch.set(docRef, service.toMap());
      }

      await batch.commit();
      developer.log(
        'Sync complete: ${vehicles.length} vehicles, ${services.length} services',
      );
    } catch (e) {
      developer.log('Error during batch sync', error: e.toString());
    }
  }
}
