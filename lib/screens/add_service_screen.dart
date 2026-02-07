import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/vehicle_model.dart';
import '../models/service_model.dart';
import '../providers/vehicle_provider.dart';
import '../services/location_service.dart';
import '../services/image_service.dart';
import '../widgets/service_photo_gallery.dart';

class AddServiceScreen extends ConsumerStatefulWidget {
  final Vehicle vehicle;

  const AddServiceScreen({super.key, required this.vehicle});

  @override
  ConsumerState<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends ConsumerState<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _odometerController = TextEditingController();
  final _costController = TextEditingController();
  final _reminderOdometerController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _hasReminder = false;
  DateTime? _reminderDate;
  int? _reminderOdometer;
  bool _isLoadingLocation = false;
  final List<String> _photoPaths = [];
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _serviceTypes = [
    'Oil Change',
    'Tire Rotation',
    'Tire Change',
    'Brake Service',
    'Engine Repair',
    'Transmission Service',
    'Battery Replacement',
    'Air Filter',
    'Coolant',
    'Inspection',
    'Other',
  ];

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _descriptionController.dispose();
    _odometerController.dispose();
    _costController.dispose();
    _reminderOdometerController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectReminderDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _reminderDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _reminderDate = picked;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    final location = await LocationService.getCurrentLocation();

    setState(() {
      _isLoadingLocation = false;
    });

    if (location != null) {
      _locationController.text = location;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to get location. Please enable location services.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickPhotos() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          // Add selected image paths
          for (final image in images) {
            _photoPaths.add(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking photos: $e')));
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );

      if (image != null) {
        setState(() {
          _photoPaths.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
      }
    }
  }

  void _deletePhoto(int index) {
    setState(() {
      _photoPaths.removeAt(index);
    });
  }

  Future<void> _showPhotoSourceDialog() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Photos'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhotos();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _saveService() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final uuid = const Uuid();
      final serviceId = uuid.v4();

      // Compress and save photos
      List<String>? savedPhotoPaths;
      if (_photoPaths.isNotEmpty) {
        savedPhotoPaths = await ImageService.compressAndSaveMultipleImages(
          _photoPaths,
          serviceId,
        );
      }

      final service = ServiceRecord(
        id: serviceId,
        vehicleId: widget.vehicle.id,
        date: _selectedDate,
        description: _descriptionController.text.trim(),
        cost: double.parse(_costController.text.trim()),
        odometerReading: int.parse(_odometerController.text.trim()),
        serviceType: _serviceTypeController.text.trim(),
        hasReminder: _hasReminder,
        reminderDate: _reminderDate,
        reminderOdometer: _reminderOdometer,
        serviceLocation:
            _locationController.text.trim().isNotEmpty
                ? _locationController.text.trim()
                : null,
        photosPaths: savedPhotoPaths,
      );

      await ref.read(vehicleProvider.notifier).addServiceRecord(service);

      // Force refresh of vehicle list
      ref.invalidate(vehicleProvider);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pop(context); // Close form
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Service Record'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Vehicle Info Card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${widget.vehicle.year} ${widget.vehicle.make} ${widget.vehicle.model}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Service Date
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Service Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  dateFormat.format(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Service Type
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Service Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.build),
              ),
              items:
                  _serviceTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _serviceTypeController.text = value;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a service type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Odometer Reading
            TextFormField(
              controller: _odometerController,
              decoration: const InputDecoration(
                labelText: 'Odometer Reading',
                hintText: 'Enter odometer reading',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.speed),
                suffixText: 'miles',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the odometer reading';
                }
                final reading = int.tryParse(value.trim());
                if (reading == null) {
                  return 'Please enter a valid number';
                }
                if (reading < 0) {
                  return 'Reading cannot be negative';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Cost
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Cost',
                hintText: '0.00',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                prefixText: 'RM ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the cost';
                }
                final cost = double.tryParse(value.trim());
                if (cost == null) {
                  return 'Please enter a valid amount';
                }
                if (cost < 0) {
                  return 'Cost cannot be negative';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Details about the service...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Service Location
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Service Location (Optional)',
                hintText: 'Enter service location',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon:
                    _isLoadingLocation
                        ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                        : IconButton(
                          icon: const Icon(Icons.my_location),
                          tooltip: 'Use current location',
                          onPressed: _getCurrentLocation,
                        ),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),
            // Photo Gallery Section
            ServicePhotoGallery(
              photoPaths: _photoPaths,
              isEditable: true,
              onAddPhotos: _showPhotoSourceDialog,
              onDeletePhoto: _deletePhoto,
            ),
            const SizedBox(height: 24),
            // Reminder Section
            Card(
              color: const Color(0xFF1A1F28),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.notifications_active,
                          color: Color(0xFF2E7CF6),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Service Reminder',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _hasReminder,
                          onChanged: (value) {
                            setState(() {
                              _hasReminder = value;
                              if (!value) {
                                _reminderDate = null;
                                _reminderOdometer = null;
                                _reminderOdometerController.clear();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if (_hasReminder) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Get reminded when to perform next service',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8B95A5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Reminder Date
                      InkWell(
                        onTap: _selectReminderDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Remind me on',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_month),
                          ),
                          child: Text(
                            _reminderDate != null
                                ? DateFormat(
                                  'MMM dd, yyyy',
                                ).format(_reminderDate!)
                                : 'Select date',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  _reminderDate != null
                                      ? Colors.white
                                      : const Color(0xFF8B95A5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Reminder Odometer
                      TextFormField(
                        controller: _reminderOdometerController,
                        decoration: const InputDecoration(
                          labelText: 'Or at odometer reading',
                          hintText: 'Enter odometer reading',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.speed),
                          suffixText: 'miles',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          setState(() {
                            _reminderOdometer =
                                value.isNotEmpty ? int.tryParse(value) : null;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Save Button
            ElevatedButton(
              onPressed: _saveService,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Save Service Record',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
