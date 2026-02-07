import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../models/vehicle_model.dart';
import '../providers/vehicle_provider.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _vinController = TextEditingController();
  final _mileageController = TextEditingController();
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();
  int _selectedColor = 0xFF2E7CF6; // Default blue

  // Predefined color palette
  final List<int> _colorPalette = [
    0xFF2E7CF6, // Blue
    0xFFEF5350, // Red
    0xFF66BB6A, // Green
    0xFFFFA726, // Orange
    0xFFAB47BC, // Purple
    0xFF26C6DA, // Cyan
    0xFFFFEE58, // Yellow
    0xFFEC407A, // Pink
    0xFF78909C, // Blue Grey
    0xFF8D6E63, // Brown
    0xFF9CCC65, // Light Green
    0xFF42A5F5, // Light Blue
  ];

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagePath = image.path;
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

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1F28),
            title: const Text(
              'Select Image Source',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF2E7CF6),
                  ),
                  title: const Text(
                    'Gallery',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF2E7CF6),
                  ),
                  title: const Text(
                    'Camera',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                if (_imagePath != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Remove Image',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _imagePath = null;
                      });
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      final uuid = const Uuid();
      final vehicle = Vehicle(
        id: uuid.v4(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        vin: _vinController.text.trim(),
        currentMileage: int.parse(_mileageController.text.trim()),
        imagePath: _imagePath,
        color: _selectedColor,
      );

      await ref.read(vehicleProvider.notifier).addVehicle(vehicle);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Vehicle Image
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F28),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2E7CF6), width: 2),
                ),
                child:
                    _imagePath != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error,
                                      size: 48,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Error loading image',
                                      style: TextStyle(
                                        color: Color(0xFF8B95A5),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                        : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 64,
                                color: Color(0xFF2E7CF6),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to add vehicle photo',
                                style: TextStyle(color: Color(0xFF8B95A5)),
                              ),
                            ],
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 24),

            // Color Picker
            const Text(
              'Vehicle Color',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  _colorPalette.map((color) {
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: Color(
                                        color,
                                      ).withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                  : null,
                        ),
                        child:
                            isSelected
                                ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 28,
                                )
                                : null,
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),
            // Make
            TextFormField(
              controller: _makeController,
              decoration: const InputDecoration(
                labelText: 'Make',
                hintText: 'e.g., Toyota, Honda, Ford',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the vehicle make';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Model
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model',
                hintText: 'e.g., Camry, Civic, F-150',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_offer),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the vehicle model';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Year
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                hintText: 'e.g., 2020',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the year';
                }
                final year = int.tryParse(value.trim());
                if (year == null) {
                  return 'Please enter a valid year';
                }
                if (year < 1900 || year > DateTime.now().year + 1) {
                  return 'Please enter a valid year';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // VIN (Optional)
            TextFormField(
              controller: _vinController,
              decoration: const InputDecoration(
                labelText: 'VIN (Optional)',
                hintText: 'Vehicle Identification Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.confirmation_number),
              ),
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [LengthLimitingTextInputFormatter(17)],
            ),
            const SizedBox(height: 16),
            // Current Mileage
            TextFormField(
              controller: _mileageController,
              decoration: const InputDecoration(
                labelText: 'Current Mileage',
                hintText: 'e.g., 50000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.speed),
                suffixText: 'miles',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the current mileage';
                }
                final mileage = int.tryParse(value.trim());
                if (mileage == null) {
                  return 'Please enter a valid mileage';
                }
                if (mileage < 0) {
                  return 'Mileage cannot be negative';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            // Save Button
            ElevatedButton(
              onPressed: _saveVehicle,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Vehicle', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
