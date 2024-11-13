import 'package:flutter/material.dart';
import 'package:flutter_application_2/camera_provider.dart';
import 'package:flutter_application_2/camera_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CameraProvider(),
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(),
    );
  }
}
