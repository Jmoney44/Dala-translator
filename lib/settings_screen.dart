import 'package:flutter/material.dart';

import 'components/bottom_navbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      bottomNavigationBar: CustomNavigationBar(currentIndex: 3),
      body: Center(
        child: Text("Settings Screen"),
      ),
    );
  }
}
