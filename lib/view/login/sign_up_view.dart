import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackizer/view/login/sign_in_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../common/color_extension.dart';
import '../../common_widget/primary_button.dart';
import '../../common_widget/round_textfield.dart';
import '../../common_widget/secondary_boutton.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirm = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool doPasswordsMatch(String password, String confirmPassword) {
                  return password == confirmPassword;
  }

  bool isValidEmail(String email) {
                // Biểu thức chính quy kiểm tra email hợp lệ
                String emailPattern = r'^[^@]+@[^@]+\.[^@]+';
                RegExp regExp = RegExp(emailPattern);
                
                return regExp.hasMatch(email);
              }

      void showSnackBarMessage(BuildContext context, String message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }

  Future<void> signUpWithEmail() async {
    String email = txtEmail.text.trim();
    String password = txtPassword.text.trim();
    String confirmPassword = txtConfirm.text.trim();

    if (!isValidEmail(email)) {
      showSnackBarMessage(context, "Invalid email address");
      return;
    }

    if (!doPasswordsMatch(password, confirmPassword)) {
      showSnackBarMessage(context, "Passwords do not match");
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInView()),
      );
      showSnackBarMessage(context, "Sign up successful!");
    } catch (e) {
      showSnackBarMessage(context, "Sign up failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: const Color(0xFFb32a45),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Center(
                  child: Image.asset(
                    "assets/img/app_logo.png",
                  width: media.width,
                  fit: BoxFit.fitWidth,
                  ),
              ),
              const SizedBox(
                height: 50,
              ),

              const SizedBox(height: 50),
              RoundTextField(
                title: "E-mail address",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
                
              ),
              const SizedBox(
                height: 15,
              ),
              const SizedBox(height: 15),
              RoundTextField(
                title: "Password",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              RoundTextField(
                title: "Confirm Password",
                controller: txtConfirm,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                title: "Let's go",
                onPressed: signUpWithEmail,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
