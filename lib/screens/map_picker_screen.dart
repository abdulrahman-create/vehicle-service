import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class MapPickerScreen extends StatelessWidget {
  final LatLong? initialLocation;

  const MapPickerScreen({super.key, this.initialLocation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Location')),
      body: FlutterLocationPicker(
        initPosition:
            initialLocation ??
            LatLong(3.139, 101.6869), // Default to Kuala Lumpur
        selectLocationButtonText: 'Select this location',
        userAgent: 'com.vehica.service',
        searchBarHintText: 'Search for place...',
        onPicked: (pickedData) {
          Navigator.pop(context, {
            'address': pickedData.address,
            'latitude': pickedData.latLong.latitude,
            'longitude': pickedData.latLong.longitude,
          });
        },
      ),
    );
  }
}
