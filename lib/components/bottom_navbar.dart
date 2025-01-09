import 'package:flutter/material.dart';
import 'package:google/Feature/community/screens/chat_screen.dart';
import 'package:google/Feature/translator/screens/camera_screen.dart';
import 'package:google/Feature/translator/screens/history_screen.dart';
import 'package:google/Feature/translator/screens/translator.dart';

class CustomNavigationBar extends StatefulWidget {
  final int currentIndex;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: const [
        NavigationDestination(
          selectedIcon: Icon(Icons.translate_sharp),
          icon: Icon(Icons.translate),
          label: 'Translate',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.history),
          icon: Icon(Icons.history_toggle_off_rounded),
          label: 'History',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.camera_alt_rounded),
          icon: Icon(Icons.camera_alt_outlined),
          label: 'Camera',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.chat_bubble_rounded),
          icon: Icon(Icons.chat_bubble_outline_rounded),
          label: 'Community',
        ),
      ],
      selectedIndex: widget.currentIndex,
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, TranslatorScreen.routeName);
            break;
          case 1:
            Navigator.pushNamed(context, HistoryScreen.routeName);
            break;
          case 2:
            Navigator.pushNamed(context, CameraScreen.routeName);
            break;
          case 3:
            Navigator.pushNamed(context, ChatScreen.routeName);
            break;
        }
      },
    );
  }
}

PageRouteBuilder<dynamic> createPageRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
