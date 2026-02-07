import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import 'settings_screen.dart';

class RemindersScreen extends ConsumerWidget {
  final VoidCallback? onNavigateToVehicles;

  const RemindersScreen({super.key, this.onNavigateToVehicles});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get all service records with reminders
    final allServiceRecords = hiveService.getAllServiceRecords();
    final upcomingReminders =
        allServiceRecords.where((service) => service.hasReminder).toList()
          ..sort((a, b) {
            // Sort by reminder date if both have it
            if (a.reminderDate != null && b.reminderDate != null) {
              return a.reminderDate!.compareTo(b.reminderDate!);
            }
            // Put services with dates first
            if (a.reminderDate != null) return -1;
            if (b.reminderDate != null) return 1;
            // Then sort by odometer
            if (a.reminderOdometer != null && b.reminderOdometer != null) {
              return a.reminderOdometer!.compareTo(b.reminderOdometer!);
            }
            return 0;
          });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Reminders'),
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
          upcomingReminders.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No reminders set',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add service records with reminders',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: onNavigateToVehicles,
                      icon: const Icon(Icons.directions_car),
                      label: const Text('Go to Vehicles'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F28),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF2E7CF6),
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'How to set reminders:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[300],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '1. Go to Vehicles tab\n2. Select a vehicle\n3. Tap "Add Service"\n4. Toggle "Service Reminder"\n5. Set date or odometer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: upcomingReminders.length,
                itemBuilder: (context, index) {
                  final service = upcomingReminders[index];
                  final vehicle = hiveService.getVehicleById(service.vehicleId);
                  final isOverdue =
                      service.reminderDate != null &&
                      service.reminderDate!.isBefore(DateTime.now());

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: const Color(0xFF1A1F28),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with service type and status
                          Row(
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
                              if (isOverdue)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFF5252,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'OVERDUE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF5252),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Vehicle info
                          if (vehicle != null)
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Color(vehicle.color),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF8B95A5),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),

                          // Reminder details
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isOverdue
                                      ? const Color(
                                        0xFFFF5252,
                                      ).withValues(alpha: 0.1)
                                      : const Color(
                                        0xFF2E7CF6,
                                      ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    isOverdue
                                        ? const Color(
                                          0xFFFF5252,
                                        ).withValues(alpha: 0.3)
                                        : const Color(
                                          0xFF2E7CF6,
                                        ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (service.reminderDate != null) ...[
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color:
                                            isOverdue
                                                ? const Color(0xFFFF5252)
                                                : const Color(0xFF2E7CF6),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormat(
                                          'MMMM dd, yyyy',
                                        ).format(service.reminderDate!),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              isOverdue
                                                  ? const Color(0xFFFF5252)
                                                  : const Color(0xFF2E7CF6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (service.reminderOdometer != null)
                                    const SizedBox(height: 8),
                                ],
                                if (service.reminderOdometer != null)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.speed,
                                        size: 16,
                                        color: Color(0xFF2E7CF6),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${NumberFormat('#,###').format(service.reminderOdometer)} km',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF2E7CF6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),

                          // Last service info
                          const SizedBox(height: 12),
                          Text(
                            'Last serviced: ${DateFormat('MMM dd, yyyy').format(service.date)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8B95A5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
