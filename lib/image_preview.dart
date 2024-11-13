import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImagePreviewScreen extends StatelessWidget {
  final List<img.Image> images;

  ImagePreviewScreen({required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Preview"),
      ),
      body: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Center(
            child: Image.memory(
              Uint8List.fromList(img.encodePng(images[index])),
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}
