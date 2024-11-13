import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/camera_provider.dart';
import 'package:flutter_application_2/image_preview.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final GlobalKey _cameraPreviewKey = GlobalKey();
  List<img.Image> capturedImages = []; // List to hold captured images

  @override
  Widget build(BuildContext context) {
    final cameraProvider = Provider.of<CameraProvider>(context);

    return Scaffold(
      body: cameraProvider.controller == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Stack(
                children: [
                  GestureDetector(
                    onTapDown: (details) {
                      cameraProvider.focusAtPoint(details);
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: CameraPreview(
                        cameraProvider.controller!,
                        key: _cameraPreviewKey,
                      ),
                    ),
                  ),
                  _buildTopControls(context),
                  // _buildThumbnailSlider(cameraProvider),
                  _buildThumbnailSlider(context),
                  _buildMiddleFrame(),
                  _buildZoomSliders(context),
                  // _buildBottomControls(cameraProvider),
                  _buildBottomControls(context),
                ],
              ),
            ),
    );
  }

  Widget _buildMiddleFrame() {
    return Center(
      child: Container(
        width: 350,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 5),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  // Top controls (unchanged)
  Widget _buildTopControls(BuildContext context) {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 40,
            ),
          ),
          IconButton(
            onPressed: () {
              Provider.of<CameraProvider>(context, listen: false).toggleFlash();
            },
            icon: const Icon(
              Icons.flash_on,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  // Thumbnail slider with delete functionality
  Widget _buildThumbnailSlider(BuildContext context) {
    return Positioned(
      top: 120, // Adjust this to position the slider under the top controls
      left: 0,
      right: 0,
      height: 100,
      child: capturedImages.isEmpty
          ? Container()
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: capturedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.memory(
                        Uint8List.fromList(
                            img.encodePng(capturedImages[index])),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Delete button overlay on the thumbnail
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red, size: 20),
                        onPressed: () {
                          setState(() {
                            capturedImages.removeAt(index); // Remove image
                          });
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  // Bottom controls with "capture" and "confirm" buttons
  Widget _buildBottomControls(BuildContext context) {
    final cameraProvider = Provider.of<CameraProvider>(context);

    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () async {
                // // Use the new capture and process method
                // await cameraProvider.captureAndProcessImage();
                // Capture the image and crop it
                final imageBytes = await cameraProvider.takePicture();
                if (imageBytes != null) {
                  final croppedImage = await cameraProvider.cropImage(
                    imageBytes,
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height,
                  );

                  setState(() {
                    capturedImages
                        .add(croppedImage); // Add cropped image to list
                  });
                }
              },
              icon: const Icon(
                Icons.camera,
                size: 70,
                color: Colors.white,
              ),
            ),
            IconButton(
              // onPressed: cameraProvider.capturedImages.isEmpty
              onPressed: capturedImages.isEmpty
                  ? null
                  : () {
                      // Once confirmed, pass the list to the PreviewScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagePreviewScreen(
                            images: capturedImages,
                          ),
                        ),
                      );
                    },
              icon: const Icon(
                Icons.check,
                size: 70,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Zoom slider (unchanged)
  Widget _buildZoomSliders(BuildContext context) {
    final cameraProvider = Provider.of<CameraProvider>(context);

    return Positioned(
      bottom: 120,
      left: 16,
      right: 16,
      child: Slider(
        value: cameraProvider.zoomLevel,
        min: 1.0,
        max: 4.0,
        onChanged: (value) {
          cameraProvider.setZoomLevel(value);
        },
      ),
    );
  }
}
