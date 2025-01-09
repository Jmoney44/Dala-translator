import 'package:flutter/material.dart';

class MainSettingsScreen extends StatelessWidget {
  static const String routeName = 'main_settings_screen';

  const MainSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Settings Screen"),
      ),
    );
  }
}
