import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/vehicle_model.dart';
import '../models/service_model.dart';
import '../providers/vehicle_provider.dart';
import '../services/location_service.dart';
import '../services/image_service.dart';
import '../widgets/service_photo_gallery.dart';

class EditServiceScreen extends ConsumerStatefulWidget {
  final Vehicle vehicle;
  final ServiceRecord service;

  const EditServiceScreen({
    super.key,
    required this.vehicle,
    required this.service,
  });

  @override
  ConsumerState<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends ConsumerState<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serviceTypeController;
  late TextEditingController _descriptionController;
  late TextEditingController _odometerController;
  late TextEditingController _costController;
  late TextEditingController _locationController;
  late DateTime _selectedDate;
  bool _isLoadingLocation = false;
  late List<String> _photoPaths;
  final List<String> _newPhotoPaths = [];
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
  void initState() {
    super.initState();
    // Initialize with existing service data
    _serviceTypeController = TextEditingController(
      text: widget.service.serviceType,
    );
    _descriptionController = TextEditingController(
      text: widget.service.description,
    );
    _odometerController = TextEditingController(
      text: widget.service.odometerReading.toString(),
    );
    _costController = TextEditingController(
      text: widget.service.cost.toStringAsFixed(2),
    );
    _locationController = TextEditingController(
      text: widget.service.serviceLocation ?? '',
    );
    _selectedDate = widget.service.date;
    _photoPaths = List<String>.from(widget.service.photosPaths ?? []);
  }

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _descriptionController.dispose();
    _odometerController.dispose();
    _costController.dispose();
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
          for (final image in images) {
            _newPhotoPaths.add(image.path);
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
          _newPhotoPaths.add(image.path);
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

  Future<void> _deletePhoto(int index) async {
    final photoPath = _photoPaths[index];

    setState(() {
      _photoPaths.removeAt(index);
      _newPhotoPaths.remove(photoPath);
    });

    // Delete the physical file if it's an existing photo (not a newly added one)
    if (!_newPhotoPaths.contains(photoPath)) {
      await ImageService.deletePhoto(photoPath);
    }
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

      // Compress and save new photos
      List<String> finalPhotoPaths = [];

      // Add existing photos (that weren't deleted)
      for (final path in _photoPaths) {
        if (!_newPhotoPaths.contains(path)) {
          finalPhotoPaths.add(path);
        }
      }

      // Compress and save new photos
      if (_newPhotoPaths.isNotEmpty) {
        final savedPaths = await ImageService.compressAndSaveMultipleImages(
          _newPhotoPaths,
          widget.service.id,
        );
        finalPhotoPaths.addAll(savedPaths);
      }

      final updatedService = ServiceRecord(
        id: widget.service.id,
        vehicleId: widget.vehicle.id,
        date: _selectedDate,
        description: _descriptionController.text.trim(),
        cost: double.parse(_costController.text.trim()),
        odometerReading: int.parse(_odometerController.text.trim()),
        serviceType: _serviceTypeController.text.trim(),
        hasReminder: widget.service.hasReminder,
        reminderDate: widget.service.reminderDate,
        reminderOdometer: widget.service.reminderOdometer,
        serviceLocation:
            _locationController.text.trim().isNotEmpty
                ? _locationController.text.trim()
                : null,
        photosPaths: finalPhotoPaths.isNotEmpty ? finalPhotoPaths : null,
      );

      final hiveService = ref.read(hiveServiceProvider);
      await hiveService.updateServiceRecord(updatedService);

      // Force refresh of vehicle list
      ref.invalidate(vehicleProvider);

      // Small delay to ensure refresh completes
      await Future.delayed(const Duration(milliseconds: 100));

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
        title: const Text('Edit Service Record'),
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
              initialValue:
                  _serviceTypes.contains(widget.service.serviceType)
                      ? widget.service.serviceType
                      : 'Other',
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
            const SizedBox(height: 32),
            // Save Button
            ElevatedButton(
              onPressed: _saveService,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Update Service Record',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
