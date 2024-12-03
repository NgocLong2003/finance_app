import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackizer/common/color_extension.dart';
import 'package:trackizer/view/login/welcome_view.dart';
import 'package:trackizer/view/main_tab/main_tab_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackizer/view/theme/theme_notifier.dart';
import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo các widget được khởi tạo
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Khởi tạo Firebase


  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),  // Provide the ThemeNotifier to the entire app
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {


    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Finance App TTNT',
          debugShowCheckedModeBanner: false,
          // theme: ThemeData(
          //   fontFamily: "Inter",
          //   colorScheme: const ColorScheme(
          //     brightness: Brightness.light,
          //     primary: Color(0xFF4CAF50),
          //     onPrimary: Colors.white,
          //     secondary: Color(0xFF80CBC4),
          //     onSecondary: Colors.black,
          //     background: Color(0xFFE0F2F1),
          //     onBackground: Colors.black,
          //     surface: Colors.white,
          //     onSurface: Colors.black,
          //     error: Colors.red,
          //     onError: Colors.white,
          //   ),
          // ),
          theme: ThemeData.light(),
          // darkTheme: ThemeData(
          //   fontFamily: "Inter",
          //   colorScheme: ColorScheme.fromSeed(
          //     seedColor: TColor.primary,
          //     background: TColor.gray80,
          //     primary: TColor.primary,
          //     primaryContainer: TColor.gray60,
          //     secondary: TColor.secondary,
          //   ),
          // ),
          darkTheme: ThemeData.dark(),
          themeMode: themeNotifier.themeMode,
          home: const WelcomeView(),
        );
      },
    );
  }
}