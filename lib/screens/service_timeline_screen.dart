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
                hintStyle: const TextStyle(color: Color(0xFF8B95A5)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7CF6)),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFF8B95A5),
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
                fillColor: const Color(0xFF1A1F28),
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

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline indicator
                        Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    vehicle != null
                                        ? Color(vehicle.color)
                                        : const Color(0xFF2E7CF6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.build,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            if (index < filteredRecords.length - 1)
                              Container(
                                width: 2,
                                height: 60,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                color: const Color(
                                  0xFF2E7CF6,
                                ).withValues(alpha: 0.3),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Content card
                        Expanded(
                          child: Card(
                            margin: EdgeInsets.zero,
                            color: const Color(0xFF1A1F28),
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
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(service.date),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF8B95A5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Vehicle Info
                                  if (vehicle != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.directions_car,
                                          size: 16,
                                          color: Color(0xFF2E7CF6),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF8B95A5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 8),

                                  // Description
                                  if (service.description.isNotEmpty)
                                    Text(
                                      service.description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF8B95A5),
                                      ),
                                    ),

                                  // Service Location
                                  if (service.serviceLocation != null &&
                                      service.serviceLocation!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Color(0xFF2E7CF6),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            service.serviceLocation!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF8B95A5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 12),

                                  // Cost and Odometer
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Cost
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF252D38),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.payments,
                                              size: 16,
                                              color: Color(0xFF2E7CF6),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'RM ${service.cost.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Odometer
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF252D38),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.speed,
                                              size: 16,
                                              color: Color(0xFF2E7CF6),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${NumberFormat('#,###').format(service.odometerReading)} km',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF8B95A5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Reminder indicator
                                  if (service.hasReminder)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF2E7CF6,
                                          ).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFF2E7CF6,
                                            ).withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.notifications_active,
                                              size: 16,
                                              color: Color(0xFF2E7CF6),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                service.reminderDate != null
                                                    ? 'Next: ${DateFormat('MMM dd, yyyy').format(service.reminderDate!)}'
                                                    : service
                                                            .reminderOdometer !=
                                                        null
                                                    ? 'Next: ${NumberFormat('#,###').format(service.reminderOdometer)} km'
                                                    : 'Reminder set',
                                                style: const TextStyle(
                                                  fontSize: 12,
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
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
