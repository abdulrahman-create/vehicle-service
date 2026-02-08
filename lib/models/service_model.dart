import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'service_model.g.dart';

@HiveType(typeId: 1)
class ServiceRecord extends HiveObject {
  @HiveField(0, defaultValue: '')
  final String id;

  @HiveField(1, defaultValue: '')
  final String vehicleId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3, defaultValue: '')
  final String description;

  @HiveField(4, defaultValue: 0.0)
  final double cost;

  @HiveField(5, defaultValue: 0)
  final int odometerReading;

  @HiveField(6, defaultValue: '')
  final String serviceType;

  @HiveField(7)
  final DateTime? reminderDate;

  @HiveField(8)
  final int? reminderOdometer;

  @HiveField(9, defaultValue: false)
  final bool hasReminder;

  @HiveField(10)
  final String? serviceLocation;

  @HiveField(11)
  final List<String>? photosPaths;

  @HiveField(12)
  final double? latitude;

  @HiveField(13)
  final double? longitude;

  ServiceRecord({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.description,
    required this.cost,
    required this.odometerReading,
    required this.serviceType,
    this.reminderDate,
    this.reminderOdometer,
    this.hasReminder = false,
    this.serviceLocation,
    this.photosPaths,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'cost': cost,
      'odometerReading': odometerReading,
      'serviceType': serviceType,
      'reminderDate': reminderDate?.millisecondsSinceEpoch,
      'reminderOdometer': reminderOdometer,
      'hasReminder': hasReminder,
      'serviceLocation': serviceLocation,
      'photosPaths': photosPaths,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory ServiceRecord.fromMap(Map<String, dynamic> map) {
    return ServiceRecord(
      id: map['id'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      date:
          map['date'] is Timestamp
              ? (map['date'] as Timestamp).toDate()
              : DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      description: map['description'] ?? '',
      cost: (map['cost'] ?? 0.0).toDouble(),
      odometerReading: map['odometerReading'] ?? 0,
      serviceType: map['serviceType'] ?? '',
      reminderDate:
          map['reminderDate'] == null
              ? null
              : (map['reminderDate'] is Timestamp
                  ? (map['reminderDate'] as Timestamp).toDate()
                  : DateTime.fromMillisecondsSinceEpoch(map['reminderDate'])),
      reminderOdometer: map['reminderOdometer'],
      hasReminder: map['hasReminder'] ?? false,
      serviceLocation: map['serviceLocation'],
      photosPaths:
          map['photosPaths'] != null
              ? List<String>.from(map['photosPaths'])
              : null,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  ServiceRecord copyWith({
    String? id,
    String? vehicleId,
    DateTime? date,
    String? description,
    double? cost,
    int? odometerReading,
    String? serviceType,
    DateTime? reminderDate,
    int? reminderOdometer,
    bool? hasReminder,
    String? serviceLocation,
    List<String>? photosPaths,
    double? latitude,
    double? longitude,
  }) {
    return ServiceRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      odometerReading: odometerReading ?? this.odometerReading,
      serviceType: serviceType ?? this.serviceType,
      reminderDate: reminderDate ?? this.reminderDate,
      reminderOdometer: reminderOdometer ?? this.reminderOdometer,
      hasReminder: hasReminder ?? this.hasReminder,
      serviceLocation: serviceLocation ?? this.serviceLocation,
      photosPaths: photosPaths ?? this.photosPaths,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
