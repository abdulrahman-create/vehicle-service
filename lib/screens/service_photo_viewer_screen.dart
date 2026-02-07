import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ServicePhotoViewerScreen extends StatefulWidget {
  final List<String> photoPaths;
  final int initialIndex;

  const ServicePhotoViewerScreen({
    super.key,
    required this.photoPaths,
    this.initialIndex = 0,
  });

  @override
  State<ServicePhotoViewerScreen> createState() =>
      _ServicePhotoViewerScreenState();
}

class _ServicePhotoViewerScreenState extends State<ServicePhotoViewerScreen> {
  late int currentIndex;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Photo ${currentIndex + 1} of ${widget.photoPaths.length}'),
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          final photoPath = widget.photoPaths[index];
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(File(photoPath)),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            heroAttributes: PhotoViewHeroAttributes(tag: photoPath),
          );
        },
        itemCount: widget.photoPaths.length,
        loadingBuilder:
            (context, event) => Center(
              child: CircularProgressIndicator(
                value:
                    event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            event.expectedTotalBytes!,
              ),
            ),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        pageController: pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.photoPaths.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == index ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
