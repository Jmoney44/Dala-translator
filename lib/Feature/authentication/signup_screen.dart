import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google/Feature/translator/screens/translator.dart';
import 'package:google/components/custom_button_widget.dart';
import 'package:google/constants/utils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SignupScreen extends StatefulWidget {
  static const String routeName = 'signup_screen';

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isLoading = false;
  final _auth = FirebaseAuth.instance;
  late String registerEmail;
  late String registerPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        opacity: 1.0,
        progressIndicator: const SpinKitWave(
          color: Colors.purpleAccent,
          size: 50.0,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Hero(
                tag: 'logo',
                child: SizedBox(
                  height: 200.0,
                  child: Image.asset(kAppLogo),
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
              TextField(
                onChanged: (value) {
                  registerEmail = value;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                onChanged: (value) {
                  registerPassword = value;
                },
                keyboardType: TextInputType.visiblePassword,
                decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your password'),
              ),
              const SizedBox(
                height: 24.0,
              ),
              CustomButtonWidget(
                color: Colors.blueAccent,
                title: "Register",
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    await _auth.createUserWithEmailAndPassword(email: registerEmail, password: registerPassword);
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, TranslatorScreen.routeName, (Route<dynamic> route) => false);
                    }
                    setState(() {
                      isLoading = false;
                    });
                  } catch (e) {
                    rethrow;
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
