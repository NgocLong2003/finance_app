import 'package:flutter/material.dart';
import 'package:trackizer/common/color_extension.dart';
import 'package:trackizer/view/login/welcome_view.dart';
import 'package:trackizer/view/main_tab/main_tab_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo các widget được khởi tạo
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Khởi tạo Firebase

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finace App TTNT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Inter",
        colorScheme: ColorScheme.fromSeed(
          seedColor: TColor.primary,
          background: TColor.gray80,
          primary: TColor.primary,
          primaryContainer: TColor.gray60,
          secondary: TColor.secondary,
        ),
        useMaterial3: false,
      ),
      home: const WelcomeView(),
    );
  }
}
