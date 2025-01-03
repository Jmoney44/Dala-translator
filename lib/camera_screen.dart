import 'package:flutter/material.dart';
import 'package:google/components/bottom_navbar.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      bottomNavigationBar: CustomNavigationBar(currentIndex: 2),
      body: Center(
        child: Text("Camera Screen"),
      ),
    );
  }
}
