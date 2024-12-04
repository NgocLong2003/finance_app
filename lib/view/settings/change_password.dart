import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/color_extension.dart';
import '../theme/theme_notifier.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Kiểm tra mật khẩu mới và xác nhận mật khẩu mới
      if (_newPasswordController.text.trim() !=
          _confirmPasswordController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verified passwords don't match")),
        );
        return;  // Dừng lại ngay lập tức nếu mật khẩu không khớp
      }

      // Lấy thông tin người dùng hiện tại
      User? user = _auth.currentUser;
      String email = user?.email ?? '';
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot find user!")),
        );
        return;
      }

      // Xác nhận mật khẩu hiện tại
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: _currentPasswordController.text.trim(),
      );
      await user?.reauthenticateWithCredential(credential);

      // Đổi mật khẩu mới
      await user?.updatePassword(_newPasswordController.text.trim());

      // Thông báo thành công và quay lại trang Settings
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Change successfully!")),
      );
      // Delay 2 giây để người dùng có thể thấy thông báo thành công trước khi quay lại màn hình
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context); // Quay lại trang Settings
    } on FirebaseAuthException catch (e) {
      // Xử lý các lỗi từ Firebase
      if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Current password is not correct!")),
        );
      } else if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("New password is too weak!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to changed password: ${e.message}")),
        );
      }
    } catch (e) {
      // Xử lý các lỗi khác
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),  // Hiển thị thông báo lỗi mà không có từ "Exception"
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    ThemeMode currentThemeMode = themeNotifier.themeMode;
    return Scaffold(
      appBar: AppBar(
        title: Text("Change password",
          style: TextStyle(color: themeNotifier.textColor,
            fontSize: 30,
            fontWeight: FontWeight.w600,),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Current password",
                labelStyle:TextStyle(color: themeNotifier.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration:  InputDecoration(
                labelText: "New password",
                labelStyle:TextStyle(color: themeNotifier.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration:  InputDecoration(
                labelText: "Verify password",
                labelStyle:TextStyle(color: themeNotifier.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,),
              ),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _changePassword,
              style: ButtonStyle(
                backgroundColor:  MaterialStateProperty.all(currentThemeMode == ThemeMode.dark
                    ? TColor.gray60.withOpacity(0.2)
                    : Colors.teal, )// Màu nền nút
              ),
                    child:  Text("Change password",
                    style:TextStyle(color: themeNotifier.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,),),

                  ),
          ],
        ),
      ),
    );
  }
}