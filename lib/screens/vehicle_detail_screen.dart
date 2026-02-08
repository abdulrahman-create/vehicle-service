import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final allTimeTotalCost = ref.watch(totalCostProvider(vehicle.id));
    final filteredTotalCost = ref.watch(filteredTotalCostProvider(vehicle.id));
    final costByType = ref.watch(costByTypeProvider(vehicle.id));

    final selectedYear = ref.watch(analyticsYearFilterProvider);
    final selectedMonth = ref.watch(analyticsMonthFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Filters',
            onPressed: () {
              ref.read(analyticsYearFilterProvider.notifier).state = null;
              ref.read(analyticsMonthFilterProvider.notifier).state = null;
            },
          ),
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
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      title: Text(
                        'Delete Vehicle',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to delete this vehicle and all its service records?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
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
      body:
          serviceRecords.isEmpty
              ? Column(
                children: [
                  _buildVehicleHeader(
                    context,
                    allTimeTotalCost,
                    serviceRecords,
                  ),
                  Expanded(
                    child: Center(
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
                    ),
                  ),
                ],
              )
              : ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _buildVehicleHeader(
                    context,
                    filteredTotalCost,
                    serviceRecords,
                  ),
                  if (serviceRecords.isNotEmpty) ...[
                    _buildFilters(
                      context,
                      ref,
                      serviceRecords,
                      selectedYear,
                      selectedMonth,
                    ),
                    _buildMaintenanceAnalytics(
                      context,
                      filteredTotalCost,
                      costByType,
                    ),
                  ],
                  _buildServiceHistoryHeader(context),
                  ...serviceRecords.asMap().entries.map(
                    (entry) => _ServiceRecordCard(
                      service: entry.value,
                      vehicleId: vehicle.id,
                      isFirst: entry.key == 0,
                      isLast: entry.key == serviceRecords.length - 1,
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildVehicleHeader(
    BuildContext context,
    double totalCost,
    List<ServiceRecord> serviceRecords,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
                              return Icon(
                                Icons.directions_car,
                                size: 48,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                              );
                            },
                          ),
                        )
                        : Icon(
                          Icons.directions_car,
                          size: 48,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.year} ${vehicle.make}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.model,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (vehicle.vin.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'VIN: ${vehicle.vin}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    );
  }

  Widget _buildFilters(
    BuildContext context,
    WidgetRef ref,
    List<ServiceRecord> records,
    int? selectedYear,
    int? selectedMonth,
  ) {
    final years =
        records.map((r) => r.date.year).toSet().toList()
          ..sort((a, b) => b.compareTo(a));

    final months = [
      {'value': 1, 'label': 'Jan'},
      {'value': 2, 'label': 'Feb'},
      {'value': 3, 'label': 'Mar'},
      {'value': 4, 'label': 'Apr'},
      {'value': 5, 'label': 'May'},
      {'value': 6, 'label': 'Jun'},
      {'value': 7, 'label': 'Jul'},
      {'value': 8, 'label': 'Aug'},
      {'value': 9, 'label': 'Sep'},
      {'value': 10, 'label': 'Oct'},
      {'value': 11, 'label': 'Nov'},
      {'value': 12, 'label': 'Dec'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: selectedYear,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  isExpanded: true,
                  hint: const Text(
                    'Year',
                    style: TextStyle(color: Colors.grey),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Years'),
                    ),
                    ...years.map(
                      (y) =>
                          DropdownMenuItem(value: y, child: Text(y.toString())),
                    ),
                  ],
                  onChanged: (val) {
                    ref.read(analyticsYearFilterProvider.notifier).state = val;
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: selectedMonth,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  isExpanded: true,
                  hint: const Text(
                    'Month',
                    style: TextStyle(color: Colors.grey),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Months'),
                    ),
                    ...months.map(
                      (m) => DropdownMenuItem(
                        value: m['value'] as int,
                        child: Text(m['label'] as String),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    ref.read(analyticsMonthFilterProvider.notifier).state = val;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceAnalytics(
    BuildContext context,
    double totalCost,
    Map<String, double> costByType,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_outlined, size: 20, color: Color(0xFF2E7CF6)),
              SizedBox(width: 8),
              Text(
                'Maintenance Analytics',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...costByType.entries.map((entry) {
            final percentage = entry.value / (totalCost > 0 ? totalCost : 1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'RM ${entry.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor:
                          Theme.of(context).colorScheme.outlineVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildServiceHistoryHeader(BuildContext context) {
    return Padding(
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
                  builder: (context) => AddServiceScreen(vehicle: vehicle),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Service'),
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
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ServiceRecordCard extends ConsumerWidget {
  final ServiceRecord service;
  final String vehicleId;
  final bool isFirst;
  final bool isLast;

  const _ServiceRecordCard({
    required this.service,
    required this.vehicleId,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Timeline Line and Dot
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Container(
                    width: 2,
                    height: 24,
                    color:
                        isFirst
                            ? Colors.transparent
                            : Theme.of(context).colorScheme.outlineVariant,
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color:
                          isLast
                              ? Colors.transparent
                              : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // The Card Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Dismissible(
                  key: Key(service.id),
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            title: Text(
                              'Delete Record',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to delete this service record?',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
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
                    await ref
                        .read(vehicleProvider.notifier)
                        .deleteServiceRecord(service.id);
                  },
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: InkWell(
                      onTap: () async {
                        final vehicle = ref
                            .read(vehicleProvider)
                            .firstWhere((v) => v.id == vehicleId);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditServiceScreen(
                                  vehicle: vehicle,
                                  service: service,
                                ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
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
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                Text(
                                  'RM ${service.cost.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  dateFormat.format(service.date),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.speed,
                                  size: 14,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${service.odometerReading} miles',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            if (service.serviceLocation != null &&
                                service.serviceLocation!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              InkWell(
                                onTap:
                                    (service.latitude != null &&
                                            service.longitude != null)
                                        ? () async {
                                          final url = Uri.parse(
                                            'https://www.google.com/maps/search/?api=1&query=${service.latitude},${service.longitude}',
                                          );
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(
                                              url,
                                              mode:
                                                  LaunchMode
                                                      .externalApplication,
                                            );
                                          }
                                        }
                                        : null,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        service.serviceLocation!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          decoration:
                                              (service.latitude != null &&
                                                      service.longitude != null)
                                                  ? TextDecoration.underline
                                                  : null,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (service.description.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                service.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            if (service.photosPaths != null &&
                                service.photosPaths!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.photo_library,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${service.photosPaths!.length} ${service.photosPaths!.length == 1 ? "photo" : "photos"}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
