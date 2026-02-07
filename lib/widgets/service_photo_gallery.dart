import 'dart:io';
import 'package:flutter/material.dart';
import '../screens/service_photo_viewer_screen.dart';

class ServicePhotoGallery extends StatelessWidget {
  final List<String> photoPaths;
  final VoidCallback? onAddPhotos;
  final Function(int index)? onDeletePhoto;
  final bool isEditable;

  const ServicePhotoGallery({
    super.key,
    required this.photoPaths,
    this.onAddPhotos,
    this.onDeletePhoto,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (photoPaths.isEmpty && !isEditable) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attached Photos (${photoPaths.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (isEditable && onAddPhotos != null)
              TextButton.icon(
                onPressed: onAddPhotos,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Photos'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (photoPaths.isEmpty && isEditable)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No photos attached',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: photoPaths.length,
            itemBuilder: (context, index) {
              return _buildPhotoThumbnail(context, index);
            },
          ),
      ],
    );
  }

  Widget _buildPhotoThumbnail(BuildContext context, int index) {
    final photoPath = photoPaths[index];
    final file = File(photoPath);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ServicePhotoViewerScreen(
                  photoPaths: photoPaths,
                  initialIndex: index,
                ),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                file.existsSync()
                    ? Image.file(file, fit: BoxFit.cover)
                    : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
          ),
          if (isEditable && onDeletePhoto != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _confirmDelete(context, index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          // Photo indicator
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${index + 1}/${photoPaths.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Photo'),
            content: const Text('Are you sure you want to delete this photo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && onDeletePhoto != null) {
      onDeletePhoto!(index);
    }
  }
}
