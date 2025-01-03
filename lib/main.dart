import 'package:flutter/material.dart';
import 'package:google/Feature/translator/translator.dart';
import 'package:google/camera_screen.dart';
import 'package:google/history_screen.dart';
import 'package:google/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'DALA Translator',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      initialRoute: '/translate',
      routes: {
        '/translate': (context) => const TranslatorScreen(),
        '/history': (context) => const HistoryScreen(),
        '/camera': (context) => const CameraScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
