import 'package:hive/hive.dart';

part 'service_model.g.dart';

@HiveType(typeId: 1)
class ServiceRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String vehicleId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final double cost;

  @HiveField(5)
  final int odometerReading;

  @HiveField(6)
  final String serviceType;

  @HiveField(7)
  final DateTime? reminderDate;

  @HiveField(8)
  final int? reminderOdometer;

  @HiveField(9)
  final bool hasReminder;

  @HiveField(10)
  final String? serviceLocation;

  @HiveField(11)
  final List<String>? photosPaths;

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
  });

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
    );
  }
}
