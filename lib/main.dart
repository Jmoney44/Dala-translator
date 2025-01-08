import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google/Feature/translator/translator.dart';
import 'package:google/camera_screen.dart';
import 'package:google/firebase_options.dart';
import 'package:google/history_screen.dart';
import 'package:google/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
