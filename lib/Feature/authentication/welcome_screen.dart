import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google/Feature/authentication/login_screen.dart';
import 'package:google/Feature/authentication/signup_screen.dart';
import 'package:google/components/custom_button_widget.dart';
import 'package:google/constants/utils.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  static const String routeName = 'welcome_screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation animationValueWidget;

  @override
  void initState() {
    super.initState();
    animationControllerFunc();
    curvedAnimation();
  }

  void animationControllerFunc() {
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    animationController.reverse(from: 1);
    animationController.addListener(() {
      setState(() {
        animationController.value;
      });
    });
  }

  void curvedAnimation() {
    animationValueWidget = CurvedAnimation(parent: animationController, curve: Curves.easeIn);
    animationValueWidget.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse(from: 1);
      } else if (status == AnimationStatus.dismissed) {
        animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Hero(
                    tag: 'logo',
                    child: SizedBox(
                      height: 100,
                      child: Image.asset(kAppLogo),
                    ),
                  ),
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Dala',
                      textStyle: const TextStyle(
                        fontSize: 45.0,
                        fontWeight: FontWeight.w900,
                      ),
                      speed: const Duration(milliseconds: 200),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 48.0,
            ),
            CustomButtonWidget(
              title: 'Log In',
              color: Colors.lightBlueAccent,
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.routeName);
              },
            ),
            CustomButtonWidget(
              title: 'Register',
              color: Colors.blueAccent,
              onPressed: () {
                Navigator.pushNamed(context, SignupScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
