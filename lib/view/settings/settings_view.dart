import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/color_extension.dart';
import '../../common_widget/icon_item_row.dart';
import '../login/welcome_view.dart';
import '../theme/theme_notifier.dart';
import 'change_password.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isActive = false;

  void _logout() {
    // Add your logout logic here (e.g., clearing user session, Firebase sign out, etc.)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeView()),
          (route) => false, // Removes all the previous routes
    );
  }
  // void _changePassword() async {
  //   final TextEditingController newPasswordController = TextEditingController();
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text("Change Password"),
  //         content: TextField(
  //           controller: newPasswordController,
  //           obscureText: true,
  //           decoration: const InputDecoration(
  //             hintText: "Enter new password",
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context), // Đóng hộp thoại
  //             child: const Text("Cancel"),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               String newPassword = newPasswordController.text.trim();
  //
  //               if (newPassword.isEmpty) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(
  //                     content: Text("Password cannot be empty."),
  //                     backgroundColor: Colors.red,
  //                   ),
  //                 );
  //                 return;
  //               }
  //
  //               try {
  //                 User? user = FirebaseAuth.instance.currentUser;
  //                 if (user != null) {
  //                   await user.updatePassword(newPassword);
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(
  //                       content: Text("Password updated successfully."),
  //                       backgroundColor: Colors.green,
  //                     ),
  //                   );
  //                 } else {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(
  //                       content: Text("No user is currently signed in."),
  //                       backgroundColor: Colors.red,
  //                     ),
  //                   );
  //                 }
  //                 Navigator.pop(context); // Đóng hộp thoại sau khi đổi mật khẩu thành công
  //               } catch (e) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     content: Text("Error: ${e.toString()}"),
  //                     backgroundColor: Colors.red,
  //                   ),
  //                 );
  //               }
  //             },
  //             child: const Text("Save"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    ThemeMode currentThemeMode = themeNotifier.themeMode;
    print(currentThemeMode);
    var media = MediaQuery.sizeOf(context);
    User? currentUser = FirebaseAuth.instance.currentUser;
    String email =
        currentUser?.email ?? 'No email available'; // Default if no email found

    return Scaffold(
      backgroundColor: themeNotifier.backgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.asset("assets/img/back.png",
                            width: 25,
                            height: 25,
                            color: currentThemeMode == ThemeMode.dark
                                ? TColor.gray30
                                : Colors.black))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Settings",
                      style: TextStyle(
                          color: currentThemeMode == ThemeMode.dark
                              ? TColor.gray30
                              : Colors.black,
                          fontSize: 16),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/img/u1.png",
                  width: 70,
                  height: 70,
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  email,
                  style: TextStyle(
                      color: themeNotifier.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                )
              ],
            ),
            const SizedBox(height: 4),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 20, bottom: 8),
                  //   child: Text(
                  //     "My subscription",
                  //     style: TextStyle(
                  //         color: themeNotifier.textColor,
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w600),
                  //   ),
                  // ),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(vertical: 8),
                  //   decoration: BoxDecoration(
                  //     border: Border.all(
                  //       color: TColor.border.withOpacity(0.1),
                  //     ),
                  //     color: currentThemeMode == ThemeMode.dark ? TColor.gray60.withOpacity(0.2) : Colors.teal,
                  //     borderRadius: BorderRadius.circular(16),
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       IconItemRow(
                  //         title: "Sorting",
                  //         icon: "assets/img/sorting.png",
                  //         value: "Date",
                  //       ),
                  //       IconItemRow(
                  //         title: "Summary",
                  //         icon: "assets/img/chart.png",
                  //         value: "Average",
                  //       ),
                  //       IconItemRow(
                  //         title: "Default currency",
                  //         icon: "assets/img/money.png",
                  //         value: "USD (\$)",
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 8),
                    child: Text(
                      "Appearance",
                      style: TextStyle(
                          color: themeNotifier.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: TColor.border.withOpacity(0.1),
                      ),
                      color: currentThemeMode == ThemeMode.dark
                          ? TColor.gray60.withOpacity(0.2)
                          : Colors.teal,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        IconItemSwitchRow(
                          title: "Dark",
                          icon: "assets/img/light_theme.png",
                          value: context.watch<ThemeNotifier>().themeMode ==
                              ThemeMode.dark,
                          didChange: (newVal) {
                            print(
                                "New Value: $newVal"); // Kiểm tra khi thay đổi theme
                            context.read<ThemeNotifier>().toggleTheme();
                          },
                        ),
                      ],
                    ),
                  ),
                  // Move Logout button out of the IconItemSwitchRow container
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Authentication",
                          style: TextStyle(
                              color: themeNotifier.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChangePasswordView(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentThemeMode == ThemeMode.dark
                                ? TColor.gray60.withOpacity(0.2)
                                : Colors.teal, // Màu nền nút
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16), // Bo góc nút
                            ),
                          ),
                          icon: Icon(
                            Icons.lock, // Icon Change Password
                            color: themeNotifier.textColor,
                          ),
                          label: Text(
                            "Change Password",
                            style: TextStyle(
                              color: themeNotifier.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _logout, // Gọi hàm _logout khi bấm nút
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentThemeMode == ThemeMode.dark
                                ? TColor.gray60.withOpacity(0.2)
                                : Colors.teal, // Màu nền nút
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16), // Bo góc nút
                            ),
                          ),
                          icon: Icon(
                            Icons.logout, // Icon Logout
                            color: themeNotifier.textColor,
                          ),
                          label: Text(
                            "Logout",
                            style: TextStyle(
                              color: themeNotifier.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
