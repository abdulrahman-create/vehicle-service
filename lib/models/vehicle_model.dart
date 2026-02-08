import 'package:hive/hive.dart';

part 'vehicle_model.g.dart';

@HiveType(typeId: 0)
class Vehicle extends HiveObject {
  @HiveField(0, defaultValue: '')
  final String id;

  @HiveField(1, defaultValue: '')
  final String make;

  @HiveField(2, defaultValue: '')
  final String model;

  @HiveField(3, defaultValue: 0)
  final int year;

  @HiveField(4, defaultValue: '')
  final String vin;

  @HiveField(5, defaultValue: 0)
  int currentMileage;

  @HiveField(6)
  String? imagePath;

  @HiveField(7, defaultValue: 0xFF2E7CF6)
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'vin': vin,
      'currentMileage': currentMileage,
      'imagePath': imagePath,
      'color': color,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] ?? '',
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? 0,
      vin: map['vin'] ?? '',
      currentMileage: map['currentMileage'] ?? 0,
      imagePath: map['imagePath'],
      color: map['color'] ?? 0xFF2E7CF6,
    );
  }

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
