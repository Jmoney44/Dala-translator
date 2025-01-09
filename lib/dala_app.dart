import 'package:flutter/material.dart';
import 'package:google/Feature/app_settings/main_settings_screen.dart';
import 'package:google/Feature/authentication/login_screen.dart';
import 'package:google/Feature/authentication/signup_screen.dart';
import 'package:google/Feature/authentication/welcome_screen.dart';
import 'package:google/Feature/community/screens/chat_screen.dart';
import 'package:google/Feature/translator/screens/camera_screen.dart';
import 'package:google/Feature/translator/screens/history_screen.dart';
import 'package:google/Feature/translator/screens/translator.dart';

class DalaApp extends StatelessWidget {
  const DalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.routeName,
      routes: {
        WelcomeScreen.routeName: (_) => const WelcomeScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignupScreen.routeName: (_) => const SignupScreen(),
        TranslatorScreen.routeName: (_) => const TranslatorScreen(),
        HistoryScreen.routeName: (_) => const HistoryScreen(),
        CameraScreen.routeName: (_) => const CameraScreen(),
        ChatScreen.routeName: (_) => const ChatScreen(),
        MainSettingsScreen.routeName: (_) => const MainSettingsScreen(),
      },
    );
  }
}
