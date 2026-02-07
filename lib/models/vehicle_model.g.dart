// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VehicleAdapter extends TypeAdapter<Vehicle> {
  @override
  final int typeId = 0;

  @override
  Vehicle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vehicle(
      id: fields[0] as String,
      make: fields[1] as String,
      model: fields[2] as String,
      year: fields[3] as int,
      vin: fields[4] as String,
      currentMileage: fields[5] as int,
      imagePath: fields[6] as String?,
      color: fields[7] as int? ?? 0xFF2E7CF6,
    );
  }

  @override
  void write(BinaryWriter writer, Vehicle obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.make)
      ..writeByte(2)
      ..write(obj.model)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.vin)
      ..writeByte(5)
      ..write(obj.currentMileage)
      ..writeByte(6)
      ..write(obj.imagePath)
      ..writeByte(7)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
