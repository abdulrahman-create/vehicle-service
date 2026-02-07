import 'package:hive/hive.dart';

part 'vehicle_model.g.dart';

@HiveType(typeId: 0)
class Vehicle extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String make;

  @HiveField(2)
  final String model;

  @HiveField(3)
  final int year;

  @HiveField(4)
  final String vin;

  @HiveField(5)
  int currentMileage;

  @HiveField(6)
  String? imagePath;

  @HiveField(7)
  int color; // Store color as int value

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.vin = '',
    required this.currentMileage,
    this.imagePath,
    this.color = 0xFF2E7CF6, // Default blue color
  });

  Vehicle copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? vin,
    int? currentMileage,
    String? imagePath,
    int? color,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      currentMileage: currentMileage ?? this.currentMileage,
      imagePath: imagePath ?? this.imagePath,
      color: color ?? this.color,
    );
  }
}
