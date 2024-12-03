import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackizer/view/login/sign_up_view.dart';
import 'package:trackizer/view/main_tab/main_tab_view.dart';
import '../../common/color_extension.dart';
import '../../common_widget/primary_button.dart';
import '../../common_widget/round_textfield.dart';
import '../../common_widget/secondary_boutton.dart';
import 'package:trackizer/view/add_subscription/add_templates.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool isRemember = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      addSampleCardsForUser(context);
      addSampleCategoriesForUser(context);
      // Đăng nhập thành công, điều hướng đến MainTabView (giả định đã có trang này)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainTabView()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Đăng nhập không thành công";
      if (e.code == 'user-not-found') {
        message = 'Không tìm thấy người dùng với email này.';
      } else if (e.code == 'wrong-password') {
        message = 'Mật khẩu không đúng.';
      }
      _showErrorDialog(message);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
              const Spacer(),
              Center(
                child: Image.asset(
                  "assets/img/app_logo.png",
                  width: media.width, // Fit to screen width
                  fit: BoxFit.fitWidth, // Ensure the image fits the width
                ),
              ),
              const Spacer(),
              RoundTextField(
                title: "Login",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              RoundTextField(
                title: "Password",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isRemember = !isRemember;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isRemember
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          size: 25,
                          color: TColor.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Remember me",
                          style: TextStyle(color: TColor.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Gửi thông báo về mail
                    },
                    child: Text(
                      "Forgot password",
                      style: TextStyle(color: TColor.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                title: "Sign In",
                onPressed: () {
                  String email = txtEmail.text.trim();
                  String password = txtPassword.text.trim();

                  // Kiểm tra dữ liệu đầu vào
                  if (email.isEmpty || password.isEmpty) {
                    _showErrorDialog('Vui lòng điền đầy đủ thông tin.');
                    return;
                  }

                  // Gọi hàm đăng nhập
                  _signInWithEmailAndPassword(email, password);
                },
              ),
              const Spacer(),
              Text(
                "If you don't have an account yet?",
                textAlign: TextAlign.center,
                style: TextStyle(color: TColor.white, fontSize: 14),
              ),
              const SizedBox(height: 20),
              SecondaryButton(
                title: "Sign up",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpView(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
