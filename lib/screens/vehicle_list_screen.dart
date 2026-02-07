import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vehicle_provider.dart';
import '../models/vehicle_model.dart';
import 'vehicle_detail_screen.dart';
import 'add_vehicle_screen.dart';
import 'settings_screen.dart';

class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehicleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body:
          vehicles.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No vehicles added yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add your first vehicle',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return _VehicleCard(vehicle: vehicle);
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _VehicleCard extends ConsumerWidget {
  final Vehicle vehicle;

  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleDetailScreen(vehicle: vehicle),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Color(vehicle.color),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    vehicle.imagePath != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(vehicle.imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.directions_car,
                                size: 36,
                                color: Colors.white,
                              );
                            },
                          ),
                        )
                        : const Icon(
                          Icons.directions_car,
                          size: 36,
                          color: Colors.white,
                        ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.year} - ${vehicle.make}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B95A5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.model,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Color(0xFF8B95A5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Last Service: Aug 2023',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8B95A5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF8B95A5)),
            ],
          ),
        ),
      ),
    );
  }
}
