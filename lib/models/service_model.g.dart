// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServiceRecordAdapter extends TypeAdapter<ServiceRecord> {
  @override
  final int typeId = 1;

  @override
  ServiceRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServiceRecord(
      id: fields[0] as String,
      vehicleId: fields[1] as String,
      date: fields[2] as DateTime,
      description: fields[3] as String,
      cost: fields[4] as double,
      odometerReading: fields[5] as int,
      serviceType: fields[6] as String,
      reminderDate: fields[7] as DateTime?,
      reminderOdometer: fields[8] as int?,
      hasReminder: fields[9] as bool? ?? false,
      serviceLocation: fields[10] as String?,
      photosPaths: (fields[11] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ServiceRecord obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vehicleId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.cost)
      ..writeByte(5)
      ..write(obj.odometerReading)
      ..writeByte(6)
      ..write(obj.serviceType)
      ..writeByte(7)
      ..write(obj.reminderDate)
      ..writeByte(8)
      ..write(obj.reminderOdometer)
      ..writeByte(9)
      ..write(obj.hasReminder)
      ..writeByte(10)
      ..write(obj.serviceLocation)
      ..writeByte(11)
      ..write(obj.photosPaths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
