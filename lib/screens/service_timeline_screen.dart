import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import 'settings_screen.dart';

class ServiceTimelineScreen extends ConsumerStatefulWidget {
  const ServiceTimelineScreen({super.key});

  @override
  ConsumerState<ServiceTimelineScreen> createState() =>
      _ServiceTimelineScreenState();
}

class _ServiceTimelineScreenState extends ConsumerState<ServiceTimelineScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get all service records from all vehicles
    final allServiceRecords =
        hiveService.getAllServiceRecords()
          ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending

    // Filter service records based on search query
    final filteredRecords =
        _searchQuery.isEmpty
            ? allServiceRecords
            : allServiceRecords.where((service) {
              final vehicle = hiveService.getVehicleById(service.vehicleId);
              final searchLower = _searchQuery.toLowerCase();

              return service.serviceType.toLowerCase().contains(searchLower) ||
                  service.description.toLowerCase().contains(searchLower) ||
                  (vehicle != null &&
                      ('${vehicle.year} ${vehicle.make} ${vehicle.model}'
                          .toLowerCase()
                          .contains(searchLower)));
            }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Timeline'),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by service type, description, or vehicle...',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7CF6)),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                        : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body:
          filteredRecords.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchQuery.isEmpty ? Icons.timeline : Icons.search_off,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No service records yet'
                          : 'No results found',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isEmpty
                          ? 'Add service records to see them here'
                          : 'Try a different search term',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredRecords.length,
                itemBuilder: (context, index) {
                  final service = filteredRecords[index];
                  final vehicle = hiveService.getVehicleById(service.vehicleId);
                  final isFirst = index == 0;
                  final isLast = index == filteredRecords.length - 1;

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Timeline indicator
                        SizedBox(
                          width: 24,
                          child: Column(
                            children: [
                              Container(
                                width: 2,
                                height: 20,
                                color:
                                    isFirst
                                        ? Colors.transparent
                                        : Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                              ),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color:
                                      vehicle != null
                                          ? Color(vehicle.color)
                                          : Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (vehicle != null
                                              ? Color(vehicle.color)
                                              : Theme.of(
                                                context,
                                              ).colorScheme.primary)
                                          .withValues(alpha: 0.4),
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
                                          : Theme.of(
                                            context,
                                          ).colorScheme.outlineVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Content card
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Card(
                              margin: EdgeInsets.zero,
                              color: Theme.of(context).colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Service Type and Date
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                          DateFormat(
                                            'MMM dd, yyyy',
                                          ).format(service.date),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Vehicle Info
                                    if (vehicle != null) ...[
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Color(
                                                vehicle.color,
                                              ).withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Icon(
                                              Icons.directions_car,
                                              size: 14,
                                              color: Color(vehicle.color),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                    ],

                                    // Description
                                    if (service.description.isNotEmpty) ...[
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
                                      const SizedBox(height: 12),
                                    ],

                                    // Service Location
                                    if (service.serviceLocation != null &&
                                        service
                                            .serviceLocation!
                                            .isNotEmpty) ...[
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Color(0xFF2E7CF6),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              service.serviceLocation!,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                    ],

                                    // Cost and Odometer
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Cost
                                        Row(
                                          children: [
                                            Text(
                                              'RM ${service.cost.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Odometer
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.speed,
                                              size: 14,
                                              color:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${NumberFormat('#,###').format(service.odometerReading)} km',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Reminder indicator
                                    if (service.hasReminder)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF2E7CF6,
                                            ).withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color(
                                                0xFF2E7CF6,
                                              ).withValues(alpha: 0.1),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.notifications_active,
                                                size: 14,
                                                color: Color(0xFF2E7CF6),
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  service.reminderDate != null
                                                      ? 'Next: ${DateFormat('MMM dd, yyyy').format(service.reminderDate!)}'
                                                      : service
                                                              .reminderOdometer !=
                                                          null
                                                      ? 'Next: ${NumberFormat('#,###').format(service.reminderOdometer)} km'
                                                      : 'Reminder set',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF2E7CF6),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
