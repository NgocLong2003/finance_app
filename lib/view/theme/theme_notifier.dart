import 'package:flutter/material.dart';

import '../../common/color_extension.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = (_themeMode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    print("Theme toggled to: $_themeMode");  // Debug print statement
    notifyListeners();
  }
  Color get textColor => isDarkMode ? Colors.white : Colors.black;
  Color get backgroundColor => isDarkMode ? TColor.gray : Colors.white;
  Color get containerColor =>isDarkMode ? TColor.gray70.withOpacity(0.5) : Colors.teal;
  Color get secondContainerColor =>isDarkMode ? TColor.gray30.withOpacity(0.3) : Colors.teal.withOpacity(0.3);
  Color get box => isDarkMode? Colors.black : Colors.white;
  Color get paddingColor => isDarkMode? TColor.gray60.withOpacity(0.2): Colors.teal.withOpacity(0.3);
  Color get selectedColor => isDarkMode? Colors.teal : Colors.white;

}