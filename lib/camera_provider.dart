// import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
// import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

class CameraProvider with ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  double zoomLevel = 1.0;
  FlashMode flashMode = FlashMode.off;
  List<img.Image> capturedImages = [];

  CameraProvider() {
    _initCamera();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras![0],
      ResolutionPreset.medium,
    );
    await _controller!.initialize();
    notifyListeners();
  }

  CameraController? get controller => _controller;

  Future<void> setZoomLevel(double level) async {
    zoomLevel = level;
    await _controller!.setZoomLevel(level);
    notifyListeners();
  }

  Future<void> toggleFlash() async {
    if (flashMode == FlashMode.off) {
      flashMode = FlashMode.torch;
    } else {
      flashMode = FlashMode.off;
    }
    await _controller!.setFlashMode(flashMode);
    notifyListeners();
  }

  Future<void> focusAtPoint(TapDownDetails details) async {
    if (_controller == null) return;

    final size = _controller!.value.previewSize!;

    // Calculate the relative position of the tap within the camera preview
    double x = details.localPosition.dx / size.width;
    double y = details.localPosition.dy / size.height;

    // Clamp the values to ensure they are between 0 and 1
    x = x.clamp(0.0, 1.0);
    y = y.clamp(0.0, 1.0);

    await _controller!.setFocusPoint(Offset(x, y));
  }

  Future<Uint8List?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }
    final XFile image = await _controller!.takePicture();
    return await image.readAsBytes();
  }

  // Future<void> captureAndProcessImage() async {
  //   // Check permissions
  //   bool isCameraGranted = await Permission.camera.request().isGranted;
  //   if (!isCameraGranted) {
  //     isCameraGranted =
  //         await Permission.camera.request() == PermissionStatus.granted;
  //   }

  //   if (!isCameraGranted) {
  //     // Have not permission to camera
  //     return;
  //   }

  //   // Generate file path for saving the image
  //   String imagePath = join(
  //     (await getApplicationSupportDirectory()).path,
  //     "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg",
  //   );

  //   // Capture the image
  //   final imageBytes = await takePicture();
  //   if (imageBytes != null) {
  //     try {
  //       // Make sure to await the call to detectEdge.
  //       bool success = await EdgeDetection.detectEdge(
  //         imagePath,
  //         canUseGallery: true,
  //         androidScanTitle: 'Scanning', // Use custom localizations for Android
  //         androidCropTitle: 'Crop',
  //         androidCropBlackWhiteTitle: 'Black White',
  //         androidCropReset: 'Reset',
  //       );

  //       if (success) {
  //         // Handle the success case
  //         // Load the cropped image from the imagePath
  //         // Assuming you have a method to load image from path
  //         Uint8List croppedImageBytes = await File(imagePath).readAsBytes();

  //         // Convert to img.Image if needed
  //         img.Image croppedImage = img.decodeImage(croppedImageBytes)!;

  //         // Add the cropped image to your list
  //         capturedImages.add(croppedImage);
  //         notifyListeners();
  //       }
  //     } catch (e) {
  //       print(e); // Handle errors
  //     }
  //   }
  // }

  Future<img.Image> cropImage(
      Uint8List imageBytes, double screenWidth, double screenHeight) async {
    // Decode the image
    img.Image originalImage = img.decodeImage(imageBytes)!;

    // Define the middle frame's width and height
    double boxWidth = 350;
    double boxHeight = 200;

    // Calculate the crop region based on the middle frame dimensions
    int x = ((originalImage.width - boxWidth) / 2).toInt();
    int y = ((originalImage.height - boxHeight) / 2).toInt();
    int width = boxWidth.toInt();
    int height = boxHeight.toInt();

    // Crop the image using the calculated dimensions
    return img.copyCrop(
      originalImage,
      x: x,
      y: y,
      width: width,
      height: height,
    );
  }

  void disposeController() {
    _controller?.dispose();
    notifyListeners();
  }
}
