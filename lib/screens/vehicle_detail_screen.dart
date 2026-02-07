import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/vehicle_model.dart';
import '../models/service_model.dart';
import '../providers/vehicle_provider.dart';
import 'add_service_screen.dart';
import 'edit_service_screen.dart';
import 'edit_vehicle_screen.dart';

class VehicleDetailScreen extends ConsumerWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceRecords = ref.watch(serviceRecordsProvider(vehicle.id));
    final totalCost = ref.watch(totalCostProvider(vehicle.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditVehicleScreen(vehicle: vehicle),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1F28),
                      title: const Text(
                        'Delete Vehicle',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Are you sure you want to delete this vehicle and all its service records?',
                        style: TextStyle(color: Color(0xFF8B95A5)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );

              if (confirm == true && context.mounted) {
                await ref
                    .read(vehicleProvider.notifier)
                    .deleteVehicle(vehicle.id);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Vehicle Details Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F28),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
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
                                      size: 48,
                                      color: Colors.white,
                                    );
                                  },
                                ),
                              )
                              : const Icon(
                                Icons.directions_car,
                                size: 48,
                                color: Colors.white,
                              ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${vehicle.year} ${vehicle.make}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8B95A5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vehicle.model,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (vehicle.vin.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'VIN: ${vehicle.vin}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8B95A5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _InfoTile(
                      icon: Icons.speed,
                      label: 'Current Mileage',
                      value: '${vehicle.currentMileage}',
                    ),
                    _InfoTile(
                      icon: Icons.attach_money,
                      label: 'Total Cost',
                      value: 'RM ${totalCost.toStringAsFixed(2)}',
                    ),
                    _InfoTile(
                      icon: Icons.build,
                      label: 'Services',
                      value: '${serviceRecords.length}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Service Records Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Service History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddServiceScreen(vehicle: vehicle),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Service'),
                ),
              ],
            ),
          ),
          // Service Records List
          Expanded(
            child:
                serviceRecords.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.build_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No service records yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: serviceRecords.length,
                      itemBuilder: (context, index) {
                        final service = serviceRecords[index];
                        return _ServiceRecordCard(
                          service: service,
                          vehicleId: vehicle.id,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ServiceRecordCard extends ConsumerWidget {
  final ServiceRecord service;
  final String vehicleId;

  const _ServiceRecordCard({required this.service, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Dismissible(
      key: Key(service.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Service Record'),
                content: const Text(
                  'Are you sure you want to delete this service record?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) async {
        final hiveService = ref.read(hiveServiceProvider);
        await hiveService.deleteServiceRecord(service.id);
        ref.invalidate(vehicleProvider);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () async {
            final vehicle = ref
                .read(vehicleProvider)
                .firstWhere((v) => v.id == vehicleId);
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        EditServiceScreen(vehicle: vehicle, service: service),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        service.serviceType,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'RM ${service.cost.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(service.date),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.speed, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${service.odometerReading} miles',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (service.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
                if (service.photosPaths != null &&
                    service.photosPaths!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.photo_library,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.photosPaths!.length} ${service.photosPaths!.length == 1 ? "photo" : "photos"}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
