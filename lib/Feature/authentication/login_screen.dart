import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google/Feature/translator/screens/translator.dart';
import 'package:google/components/custom_button_widget.dart';
import 'package:google/constants/utils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'login_screen';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  final _auth = FirebaseAuth.instance;
  late String loginEmail;
  late String loginPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  loginEmail = value;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                onChanged: (value) {
                  loginPassword = value;
                },
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your password'),
              ),
              const SizedBox(
                height: 24.0,
              ),
              CustomButtonWidget(
                color: Colors.lightBlueAccent,
                title: "Log In",
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    await _auth.signInWithEmailAndPassword(email: loginEmail, password: loginPassword);
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
